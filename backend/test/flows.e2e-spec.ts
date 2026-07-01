import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { Prisma } from '@prisma/client';
import request from 'supertest';
import { AppModule } from './../src/app.module';
import { PrismaService } from './../src/prisma/prisma.service';

/// e2e dos fluxos-chave. Cria jogadores/fixtures próprios (sufixo único) e
/// limpa tudo no final — não depende do seed nem polui o estado de demonstração.
describe('Fluxos-chave (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  let http: ReturnType<INestApplication['getHttpServer']>;

  const stamp = Date.now();
  const emailA = `e2e-a-${stamp}@test.local`;
  const emailB = `e2e-b-${stamp}@test.local`;
  let tokenA = '';
  let tokenB = '';
  let idA = '';
  let idB = '';
  let nickB = '';
  const tempOfferIds: string[] = [];
  const tempAuctionIds: string[] = [];

  const bearer = (token: string): [string, string] => ['Authorization', `Bearer ${token}`];

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true, forbidNonWhitelisted: true }));
    await app.init();
    prisma = app.get(PrismaService);
    http = app.getHttpServer();

    nickB = `E2EB${stamp}`;
    const regA = await request(http)
      .post('/api/auth/register')
      .send({ email: emailA, password: 'e2ePass123', nickname: `E2EA${stamp}` });
    tokenA = regA.body.accessToken as string;
    idA = regA.body.playerId as string;
    const regB = await request(http)
      .post('/api/auth/register')
      .send({ email: emailB, password: 'e2ePass123', nickname: nickB });
    tokenB = regB.body.accessToken as string;
    idB = regB.body.playerId as string;
  });

  afterAll(async () => {
    if (tempOfferIds.length) {
      await prisma.informalOffer.deleteMany({ where: { id: { in: tempOfferIds } } });
    }
    if (tempAuctionIds.length) {
      await prisma.auction.deleteMany({ where: { id: { in: tempAuctionIds } } });
    }
    await prisma.player.deleteMany({ where: { email: { in: [emailA, emailB] } } });
    await app.close();
  });

  it('deve registrar com tokens', () => {
    expect(tokenA).toBeTruthy();
    expect(idA).toBeTruthy();
    expect(idB).toBeTruthy();
  });

  it('novo jogador começa isolado: frota inicial, sem federação, missões frescas', async () => {
    const me = await request(http).get('/api/me').set(...bearer(tokenA)).expect(200);
    expect(me.body.level).toBe(1);
    expect(me.body.federation).toBe('');

    const fleet = await request(http).get('/api/fleet').set(...bearer(tokenA)).expect(200);
    expect(fleet.body.vehicles).toHaveLength(2);

    const fed = await request(http).get('/api/federation').set(...bearer(tokenA)).expect(200);
    expect(fed.body.inFederation).toBe(false);

    const board = await request(http).get('/api/missions/board').set(...bearer(tokenA)).expect(200);
    expect(board.body.streak).toBe(0);
    expect(board.body.missions.filter((m: { status: string }) => m.status === 'claimed')).toHaveLength(0);
  });

  it('exige autenticação nas rotas protegidas', async () => {
    await request(http).get('/api/fleet').expect(401);
  });

  it('Mercado Central: B anuncia, A compra (escrow + livro-razão)', async () => {
    // B lista Ligas Metálicas (tem 800 do starter).
    await request(http)
      .post('/api/market/listings')
      .set(...bearer(tokenB))
      .send({ key: 'alloys', quantity: 20, unitPrice: 0.05 })
      .expect(201);

    const board = await request(http).get('/api/market/board').set(...bearer(tokenA)).expect(200);
    const order = board.body.orders.find((o: { trader: string; resourceId: string }) => o.trader === nickB && o.resourceId === 'alloys');
    expect(order).toBeDefined();

    const before = await request(http).get('/api/resources').set(...bearer(tokenA));
    const alloysBefore = before.body.stocks.find((s: { key: string }) => s.key === 'alloys')?.amount ?? 0;

    await request(http)
      .post(`/api/market/listings/${order.id}/buy`)
      .set(...bearer(tokenA))
      .send({ quantity: 20 })
      .expect(201);

    const after = await request(http).get('/api/resources').set(...bearer(tokenA));
    const alloysAfter = after.body.stocks.find((s: { key: string }) => s.key === 'alloys')?.amount ?? 0;
    expect(alloysAfter).toBe(alloysBefore + 20);
  });

  it('Comércio Informal: A aceita uma oferta e troca os recursos', async () => {
    // Oferta temporária de B: dá 30 alloys, quer 10 water.
    const offer = await prisma.informalOffer.create({
      data: {
        seller: { connect: { id: idB } },
        giveKey: 'alloys',
        giveQty: 30,
        wantKey: 'water',
        wantQty: 10,
        status: 'open',
      },
    });
    tempOfferIds.push(offer.id);

    const before = await request(http).get('/api/resources').set(...bearer(tokenA));
    const waterBefore = before.body.stocks.find((s: { key: string }) => s.key === 'water')?.amount ?? 0;

    await request(http).post(`/api/informal/${offer.id}/accept`).set(...bearer(tokenA)).expect(201);

    const after = await request(http).get('/api/resources').set(...bearer(tokenA));
    const waterAfter = after.body.stocks.find((s: { key: string }) => s.key === 'water')?.amount ?? 0;
    expect(waterAfter).toBe(waterBefore - 10);
  });

  it('Leilão: bloqueado abaixo do Nível 100; lance válido acima', async () => {
    const auction = await prisma.auction.create({
      data: {
        name: `E2E Lote ${stamp}`,
        description: 'lote de teste',
        rarity: 'rare',
        status: 'live',
        currentBid: new Prisma.Decimal(1000),
        minIncrement: new Prisma.Decimal(100),
        endsAt: new Date(Date.now() + 3_600_000),
      },
    });
    tempAuctionIds.push(auction.id);

    // A (nível 1) → bloqueado.
    await request(http)
      .post(`/api/auctions/${auction.id}/bid`)
      .set(...bearer(tokenA))
      .send({ amount: 1100 })
      .expect(403);

    // Promove A a nível 100 e dá saldo.
    await prisma.player.update({ where: { id: idA }, data: { level: 100, fertBalance: new Prisma.Decimal(50000) } });

    // Abaixo do incremento mínimo → rejeitado.
    await request(http)
      .post(`/api/auctions/${auction.id}/bid`)
      .set(...bearer(tokenA))
      .send({ amount: 1050 })
      .expect(400);

    // Lance válido.
    await request(http)
      .post(`/api/auctions/${auction.id}/bid`)
      .set(...bearer(tokenA))
      .send({ amount: 1100 })
      .expect(201);

    const updated = await prisma.auction.findUniqueOrThrow({ where: { id: auction.id } });
    expect(Number(updated.currentBid)).toBe(1100);
  });
});

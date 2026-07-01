-- Concede privilégios globais ao usuário `fertways` para que o Prisma consiga
-- criar/derrubar o shadow database usado por `prisma migrate dev`.
-- (Somente para desenvolvimento local — em produção use um usuário restrito.)
GRANT ALL PRIVILEGES ON *.* TO 'fertways'@'%';
FLUSH PRIVILEGES;

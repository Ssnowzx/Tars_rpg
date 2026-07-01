-- CreateTable
CREATE TABLE `Player` (
    `id` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `passwordHash` VARCHAR(191) NOT NULL,
    `nickname` VARCHAR(191) NOT NULL,
    `avatarUrl` VARCHAR(191) NULL,
    `locale` ENUM('pt', 'es', 'en') NOT NULL DEFAULT 'pt',
    `marco` INTEGER NOT NULL DEFAULT 1,
    `level` INTEGER NOT NULL DEFAULT 1,
    `xp` INTEGER NOT NULL DEFAULT 0,
    `fertBalance` DECIMAL(18, 4) NOT NULL DEFAULT 50,
    `neutralRegistered` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `Player_email_key`(`email`),
    UNIQUE INDEX `Player_nickname_key`(`nickname`),
    INDEX `Player_level_idx`(`level`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `RefreshToken` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `tokenHash` VARCHAR(191) NOT NULL,
    `expiresAt` DATETIME(3) NOT NULL,
    `revokedAt` DATETIME(3) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `RefreshToken_tokenHash_key`(`tokenHash`),
    INDEX `RefreshToken_playerId_idx`(`playerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Reputation` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `commercialTrust` INTEGER NOT NULL DEFAULT 500,
    `socialConduct` INTEGER NOT NULL DEFAULT 500,
    `civicStatus` INTEGER NOT NULL DEFAULT 500,
    `militaryHonor` INTEGER NOT NULL DEFAULT 500,
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `Reputation_playerId_key`(`playerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ReputationEvent` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `index` ENUM('commercialTrust', 'socialConduct', 'civicStatus', 'militaryHonor') NOT NULL,
    `delta` INTEGER NOT NULL,
    `reason` VARCHAR(191) NOT NULL,
    `refType` VARCHAR(191) NULL,
    `refId` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `ReputationEvent_playerId_index_idx`(`playerId`, `index`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `DiaryEntry` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `kind` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `body` TEXT NOT NULL,
    `note` TEXT NULL,
    `isPublic` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `DiaryEntry_playerId_idx`(`playerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Colony` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `sector` VARCHAR(191) NOT NULL DEFAULT '',
    `specialization` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `Colony_playerId_key`(`playerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Building` (
    `id` VARCHAR(191) NOT NULL,
    `colonyId` VARCHAR(191) NOT NULL,
    `kind` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `category` ENUM('habitat', 'oxygen', 'water', 'metals', 'rawmetal', 'biomass', 'energy', 'components', 'biofuel', 'military', 'research', 'transport', 'special', 'empty') NOT NULL,
    `level` INTEGER NOT NULL DEFAULT 1,
    `perHour` INTEGER NOT NULL DEFAULT 0,
    `dx` DOUBLE NOT NULL DEFAULT 0,
    `dy` DOUBLE NOT NULL DEFAULT 0,
    `built` BOOLEAN NOT NULL DEFAULT true,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `Building_colonyId_idx`(`colonyId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ResourceStock` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `key` ENUM('oxygen', 'water', 'biomass', 'energy', 'metalore', 'alloys', 'chemicals', 'biofuel', 'aluminum', 'tin', 'copper', 'silicon', 'lithium', 'tungsten', 'tantalum', 'gold', 'componentBasic', 'componentIntermediate', 'componentAdvanced', 'niobium', 'helium3', 'quartz', 'redIron', 'organicResin', 'methaneIce', 'fossilPlasma', 'bioFungus') NOT NULL,
    `tier` ENUM('primary', 'industrial', 'mineral', 'component', 'rare') NOT NULL,
    `amount` INTEGER NOT NULL DEFAULT 0,
    `capacity` INTEGER NULL,
    `perHour` INTEGER NOT NULL DEFAULT 0,

    UNIQUE INDEX `ResourceStock_playerId_key_key`(`playerId`, `key`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `BuildJob` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `targetKind` VARCHAR(191) NOT NULL,
    `targetId` VARCHAR(191) NULL,
    `kind` ENUM('construct', 'upgrade') NOT NULL,
    `fromLevel` INTEGER NOT NULL DEFAULT 0,
    `toLevel` INTEGER NOT NULL DEFAULT 1,
    `totalSeconds` INTEGER NOT NULL,
    `startedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `endsAt` DATETIME(3) NOT NULL,
    `status` ENUM('queued', 'active', 'done', 'cancelled') NOT NULL DEFAULT 'active',

    INDEX `BuildJob_playerId_status_idx`(`playerId`, `status`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `LedgerEntry` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `amount` DECIMAL(18, 4) NOT NULL,
    `balanceAfter` DECIMAL(18, 4) NOT NULL,
    `reason` ENUM('contractNpc', 'marketSale', 'marketBuy', 'missionReward', 'civicPay', 'tax', 'maintenance', 'construction', 'auction', 'repair', 'subsidy', 'adminAdjust', 'transfer', 'other') NOT NULL,
    `refType` VARCHAR(191) NULL,
    `refId` VARCHAR(191) NULL,
    `ruleVersion` VARCHAR(191) NOT NULL DEFAULT 'v33',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `LedgerEntry_playerId_createdAt_idx`(`playerId`, `createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `MarketPrice` (
    `key` ENUM('oxygen', 'water', 'biomass', 'energy', 'metalore', 'alloys', 'chemicals', 'biofuel', 'aluminum', 'tin', 'copper', 'silicon', 'lithium', 'tungsten', 'tantalum', 'gold', 'componentBasic', 'componentIntermediate', 'componentAdvanced', 'niobium', 'helium3', 'quartz', 'redIron', 'organicResin', 'methaneIce', 'fossilPlasma', 'bioFungus') NOT NULL,
    `basePrice` DECIMAL(18, 4) NOT NULL,
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`key`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `MarketListing` (
    `id` VARCHAR(191) NOT NULL,
    `sellerId` VARCHAR(191) NOT NULL,
    `key` ENUM('oxygen', 'water', 'biomass', 'energy', 'metalore', 'alloys', 'chemicals', 'biofuel', 'aluminum', 'tin', 'copper', 'silicon', 'lithium', 'tungsten', 'tantalum', 'gold', 'componentBasic', 'componentIntermediate', 'componentAdvanced', 'niobium', 'helium3', 'quartz', 'redIron', 'organicResin', 'methaneIce', 'fossilPlasma', 'bioFungus') NOT NULL,
    `quantity` INTEGER NOT NULL,
    `unitPrice` DECIMAL(18, 4) NOT NULL,
    `status` ENUM('open', 'sold', 'cancelled') NOT NULL DEFAULT 'open',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `MarketListing_key_status_idx`(`key`, `status`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `MarketOrder` (
    `id` VARCHAR(191) NOT NULL,
    `listingId` VARCHAR(191) NOT NULL,
    `buyerId` VARCHAR(191) NOT NULL,
    `quantity` INTEGER NOT NULL,
    `total` DECIMAL(18, 4) NOT NULL,
    `taxPaid` DECIMAL(18, 4) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `MarketOrder_buyerId_idx`(`buyerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `TradeAgreement` (
    `id` VARCHAR(191) NOT NULL,
    `proposerId` VARCHAR(191) NOT NULL,
    `counterpartyId` VARCHAR(191) NOT NULL,
    `terms` JSON NOT NULL,
    `deadline` DATETIME(3) NULL,
    `status` ENUM('proposed', 'active', 'fulfilled', 'breached', 'cancelled') NOT NULL DEFAULT 'proposed',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `confirmedAt` DATETIME(3) NULL,

    INDEX `TradeAgreement_proposerId_idx`(`proposerId`),
    INDEX `TradeAgreement_counterpartyId_idx`(`counterpartyId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `TradeRating` (
    `id` VARCHAR(191) NOT NULL,
    `agreementId` VARCHAR(191) NULL,
    `raterId` VARCHAR(191) NOT NULL,
    `ratedId` VARCHAR(191) NOT NULL,
    `stars` INTEGER NOT NULL,
    `comment` TEXT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `TradeRating_ratedId_idx`(`ratedId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Auction` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `description` TEXT NOT NULL,
    `rarity` ENUM('unique', 'legendary', 'rare') NOT NULL,
    `status` ENUM('live', 'endingSoon', 'ended') NOT NULL DEFAULT 'live',
    `currentBid` DECIMAL(18, 4) NOT NULL,
    `minIncrement` DECIMAL(18, 4) NOT NULL,
    `endsAt` DATETIME(3) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Bid` (
    `id` VARCHAR(191) NOT NULL,
    `auctionId` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `amount` DECIMAL(18, 4) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Bid_auctionId_idx`(`auctionId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Federation` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `tag` VARCHAR(191) NULL,
    `treasury` DECIMAL(18, 4) NOT NULL DEFAULT 0,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `Federation_name_key`(`name`),
    UNIQUE INDEX `Federation_tag_key`(`tag`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `FederationMember` (
    `id` VARCHAR(191) NOT NULL,
    `federationId` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `role` ENUM('leader', 'diplomat', 'intendant', 'member') NOT NULL DEFAULT 'member',
    `joinedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `FederationMember_playerId_key`(`playerId`),
    INDEX `FederationMember_federationId_idx`(`federationId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Treaty` (
    `id` VARCHAR(191) NOT NULL,
    `federationId` VARCHAR(191) NOT NULL,
    `allyId` VARCHAR(191) NOT NULL,
    `type` ENUM('alliance', 'nonAggression', 'war') NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Treaty_federationId_idx`(`federationId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Dispute` (
    `id` VARCHAR(191) NOT NULL,
    `reporterId` VARCHAR(191) NOT NULL,
    `accusedId` VARCHAR(191) NOT NULL,
    `conciliatorId` VARCHAR(191) NULL,
    `category` VARCHAR(191) NOT NULL,
    `summary` TEXT NOT NULL,
    `status` ENUM('open', 'triage', 'assigned', 'mediation', 'decided', 'appeal', 'closed') NOT NULL DEFAULT 'open',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `Dispute_status_idx`(`status`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Evidence` (
    `id` VARCHAR(191) NOT NULL,
    `disputeId` VARCHAR(191) NOT NULL,
    `kind` ENUM('serverLog', 'tradeAgreement', 'message', 'screenshot', 'context') NOT NULL,
    `label` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Evidence_disputeId_idx`(`disputeId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `DisputeEvent` (
    `id` VARCHAR(191) NOT NULL,
    `disputeId` VARCHAR(191) NOT NULL,
    `label` VARCHAR(191) NOT NULL,
    `note` TEXT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `DisputeEvent_disputeId_idx`(`disputeId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Mission` (
    `id` VARCHAR(191) NOT NULL,
    `key` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `description` TEXT NOT NULL,
    `category` ENUM('tutorial', 'production', 'logistics', 'social', 'civic', 'military') NOT NULL,
    `rewardFert` DECIMAL(18, 4) NOT NULL DEFAULT 0,
    `rewardXp` INTEGER NOT NULL DEFAULT 0,

    UNIQUE INDEX `Mission_key_key`(`key`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PlayerMission` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `missionId` VARCHAR(191) NOT NULL,
    `status` ENUM('locked', 'available', 'active', 'ready', 'done') NOT NULL DEFAULT 'available',
    `progress` INTEGER NOT NULL DEFAULT 0,
    `target` INTEGER NOT NULL DEFAULT 1,
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `PlayerMission_playerId_missionId_key`(`playerId`, `missionId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Achievement` (
    `id` VARCHAR(191) NOT NULL,
    `key` VARCHAR(191) NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `description` TEXT NOT NULL,

    UNIQUE INDEX `Achievement_key_key`(`key`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PlayerAchievement` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `achievementId` VARCHAR(191) NOT NULL,
    `unlockedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `PlayerAchievement_playerId_achievementId_key`(`playerId`, `achievementId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `GameEvent` (
    `id` VARCHAR(191) NOT NULL,
    `key` VARCHAR(191) NOT NULL,
    `type` ENUM('narrative', 'storm', 'war', 'market', 'gagarin') NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `body` TEXT NOT NULL,
    `startsAt` DATETIME(3) NULL,
    `endsAt` DATETIME(3) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `GameEvent_key_key`(`key`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Vehicle` (
    `id` VARCHAR(191) NOT NULL,
    `ownerId` VARCHAR(191) NOT NULL,
    `kind` ENUM('van', 'truck', 'drone', 'miner', 'sentinel', 'infiltrator', 'predator', 'planetaryShip', 'freighter', 'longRange') NOT NULL,
    `plate` VARCHAR(191) NULL,
    `status` ENUM('idle', 'enRoute', 'maintenance', 'occupied') NOT NULL DEFAULT 'idle',
    `integrity` DOUBLE NOT NULL DEFAULT 1.0,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `Vehicle_plate_key`(`plate`),
    INDEX `Vehicle_ownerId_idx`(`ownerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PublicOffice` (
    `id` VARCHAR(191) NOT NULL,
    `kind` ENUM('conciliator', 'marketInspector', 'spaceportAttendant', 'reporter', 'treasuryAssistant') NOT NULL,
    `holderId` VARCHAR(191) NULL,

    UNIQUE INDEX `PublicOffice_kind_key`(`kind`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `OfficeCandidate` (
    `id` VARCHAR(191) NOT NULL,
    `officeId` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `OfficeCandidate_officeId_playerId_key`(`officeId`, `playerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `OfficePayment` (
    `id` VARCHAR(191) NOT NULL,
    `officeId` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `amount` DECIMAL(18, 4) NOT NULL,
    `period` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `OfficePayment_playerId_idx`(`playerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `NeutralZone` (
    `id` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `resource` ENUM('oxygen', 'water', 'biomass', 'energy', 'metalore', 'alloys', 'chemicals', 'biofuel', 'aluminum', 'tin', 'copper', 'silicon', 'lithium', 'tungsten', 'tantalum', 'gold', 'componentBasic', 'componentIntermediate', 'componentAdvanced', 'niobium', 'helium3', 'quartz', 'redIron', 'organicResin', 'methaneIce', 'fossilPlasma', 'bioFungus') NOT NULL,
    `level` INTEGER NOT NULL DEFAULT 1,
    `ownerId` VARCHAR(191) NULL,
    `windowStart` INTEGER NULL,
    `protectedUntil` DATETIME(3) NULL,
    `maintenancePaidAt` DATETIME(3) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `NeutralZone_ownerId_idx`(`ownerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ZoneStructure` (
    `id` VARCHAR(191) NOT NULL,
    `zoneId` VARCHAR(191) NOT NULL,
    `kind` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `level` INTEGER NOT NULL DEFAULT 1,

    INDEX `ZoneStructure_zoneId_idx`(`zoneId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Unit` (
    `id` VARCHAR(191) NOT NULL,
    `ownerId` VARCHAR(191) NOT NULL,
    `type` ENUM('sentinel', 'robo', 'infiltrator', 'predator') NOT NULL,
    `level` INTEGER NOT NULL DEFAULT 1,
    `count` INTEGER NOT NULL DEFAULT 0,
    `integrity` DOUBLE NOT NULL DEFAULT 1.0,

    INDEX `Unit_ownerId_idx`(`ownerId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Battle` (
    `id` VARCHAR(191) NOT NULL,
    `attackerId` VARCHAR(191) NOT NULL,
    `zoneId` VARCHAR(191) NOT NULL,
    `type` ENUM('invasion', 'sabotage', 'apprehension', 'siege') NOT NULL,
    `status` ENUM('pending', 'active', 'attackerWon', 'defenderWon', 'cancelled') NOT NULL DEFAULT 'pending',
    `seed` VARCHAR(191) NOT NULL,
    `lootValue` DECIMAL(18, 4) NOT NULL DEFAULT 0,
    `startedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `endedAt` DATETIME(3) NULL,

    INDEX `Battle_zoneId_idx`(`zoneId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `BattleRound` (
    `id` VARCHAR(191) NOT NULL,
    `battleId` VARCHAR(191) NOT NULL,
    `round` INTEGER NOT NULL,
    `attackForce` DOUBLE NOT NULL,
    `defenseForce` DOUBLE NOT NULL,
    `note` TEXT NULL,

    INDEX `BattleRound_battleId_idx`(`battleId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `WarRankingEntry` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `season` VARCHAR(191) NOT NULL,
    `metric` VARCHAR(191) NOT NULL,
    `value` DOUBLE NOT NULL,
    `percentile` DOUBLE NOT NULL DEFAULT 0,
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `WarRankingEntry_playerId_season_metric_key`(`playerId`, `season`, `metric`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `NpcPlanet` (
    `id` VARCHAR(191) NOT NULL,
    `key` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `distance` VARCHAR(191) NOT NULL,
    `risk` ENUM('none', 'low', 'high') NOT NULL DEFAULT 'none',
    `exports` TEXT NOT NULL,
    `imports` TEXT NOT NULL,

    UNIQUE INDEX `NpcPlanet_key_key`(`key`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Notification` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `kind` ENUM('war', 'reputation', 'gagarin', 'market', 'mission', 'federation', 'office', 'auction', 'fleet', 'system') NOT NULL,
    `severity` ENUM('info', 'success', 'warning', 'critical') NOT NULL DEFAULT 'info',
    `title` VARCHAR(191) NOT NULL,
    `body` TEXT NOT NULL,
    `route` VARCHAR(191) NULL,
    `read` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Notification_playerId_read_idx`(`playerId`, `read`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ChatChannel` (
    `id` VARCHAR(191) NOT NULL,
    `type` ENUM('global', 'regional', 'federation', 'dm', 'neighborhood') NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ChatMessage` (
    `id` VARCHAR(191) NOT NULL,
    `channelId` VARCHAR(191) NOT NULL,
    `senderId` VARCHAR(191) NOT NULL,
    `body` TEXT NOT NULL,
    `reported` BOOLEAN NOT NULL DEFAULT false,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `ChatMessage_channelId_createdAt_idx`(`channelId`, `createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `TerraformIndicator` (
    `kind` ENUM('atmosphere', 'water', 'biosphere') NOT NULL,
    `percent` INTEGER NOT NULL DEFAULT 0,
    `perDay` INTEGER NOT NULL DEFAULT 0,
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`kind`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `TerraformContribution` (
    `id` VARCHAR(191) NOT NULL,
    `playerId` VARCHAR(191) NOT NULL,
    `kind` ENUM('atmosphere', 'water', 'biosphere') NOT NULL,
    `amount` INTEGER NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `TerraformContribution_playerId_createdAt_idx`(`playerId`, `createdAt`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Moon` (
    `id` VARCHAR(191) NOT NULL,
    `key` VARCHAR(191) NOT NULL,
    `name` VARCHAR(191) NOT NULL,
    `honoree` VARCHAR(191) NOT NULL,
    `honoreeNote` VARCHAR(191) NOT NULL,
    `atmosphere` ENUM('similar', 'none', 'toxic') NOT NULL,
    `rareResource` ENUM('oxygen', 'water', 'biomass', 'energy', 'metalore', 'alloys', 'chemicals', 'biofuel', 'aluminum', 'tin', 'copper', 'silicon', 'lithium', 'tungsten', 'tantalum', 'gold', 'componentBasic', 'componentIntermediate', 'componentAdvanced', 'niobium', 'helium3', 'quartz', 'redIron', 'organicResin', 'methaneIce', 'fossilPlasma', 'bioFungus') NOT NULL,
    `profile` TEXT NOT NULL,
    `t2Reading` VARCHAR(191) NOT NULL,
    `mystery` BOOLEAN NOT NULL DEFAULT false,

    UNIQUE INDEX `Moon_key_key`(`key`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `GagarinBulletin` (
    `id` VARCHAR(191) NOT NULL,
    `cycle` VARCHAR(191) NOT NULL,
    `kind` ENUM('moon', 'atmosphere', 'resource', 'anomaly') NOT NULL,
    `title` VARCHAR(191) NOT NULL,
    `body` TEXT NOT NULL,
    `moonId` VARCHAR(191) NULL,
    `publishedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `GagarinBulletin_moonId_idx`(`moonId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ServerConfig` (
    `key` VARCHAR(191) NOT NULL,
    `value` JSON NOT NULL,
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`key`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `RefreshToken` ADD CONSTRAINT `RefreshToken_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Reputation` ADD CONSTRAINT `Reputation_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ReputationEvent` ADD CONSTRAINT `ReputationEvent_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `DiaryEntry` ADD CONSTRAINT `DiaryEntry_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Colony` ADD CONSTRAINT `Colony_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Building` ADD CONSTRAINT `Building_colonyId_fkey` FOREIGN KEY (`colonyId`) REFERENCES `Colony`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ResourceStock` ADD CONSTRAINT `ResourceStock_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `BuildJob` ADD CONSTRAINT `BuildJob_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `LedgerEntry` ADD CONSTRAINT `LedgerEntry_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `MarketListing` ADD CONSTRAINT `MarketListing_sellerId_fkey` FOREIGN KEY (`sellerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `MarketOrder` ADD CONSTRAINT `MarketOrder_listingId_fkey` FOREIGN KEY (`listingId`) REFERENCES `MarketListing`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `MarketOrder` ADD CONSTRAINT `MarketOrder_buyerId_fkey` FOREIGN KEY (`buyerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `TradeAgreement` ADD CONSTRAINT `TradeAgreement_proposerId_fkey` FOREIGN KEY (`proposerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `TradeAgreement` ADD CONSTRAINT `TradeAgreement_counterpartyId_fkey` FOREIGN KEY (`counterpartyId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `TradeRating` ADD CONSTRAINT `TradeRating_agreementId_fkey` FOREIGN KEY (`agreementId`) REFERENCES `TradeAgreement`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `TradeRating` ADD CONSTRAINT `TradeRating_raterId_fkey` FOREIGN KEY (`raterId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `TradeRating` ADD CONSTRAINT `TradeRating_ratedId_fkey` FOREIGN KEY (`ratedId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Bid` ADD CONSTRAINT `Bid_auctionId_fkey` FOREIGN KEY (`auctionId`) REFERENCES `Auction`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Bid` ADD CONSTRAINT `Bid_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `FederationMember` ADD CONSTRAINT `FederationMember_federationId_fkey` FOREIGN KEY (`federationId`) REFERENCES `Federation`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `FederationMember` ADD CONSTRAINT `FederationMember_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Treaty` ADD CONSTRAINT `Treaty_federationId_fkey` FOREIGN KEY (`federationId`) REFERENCES `Federation`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Treaty` ADD CONSTRAINT `Treaty_allyId_fkey` FOREIGN KEY (`allyId`) REFERENCES `Federation`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Dispute` ADD CONSTRAINT `Dispute_reporterId_fkey` FOREIGN KEY (`reporterId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Dispute` ADD CONSTRAINT `Dispute_accusedId_fkey` FOREIGN KEY (`accusedId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Dispute` ADD CONSTRAINT `Dispute_conciliatorId_fkey` FOREIGN KEY (`conciliatorId`) REFERENCES `Player`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Evidence` ADD CONSTRAINT `Evidence_disputeId_fkey` FOREIGN KEY (`disputeId`) REFERENCES `Dispute`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `DisputeEvent` ADD CONSTRAINT `DisputeEvent_disputeId_fkey` FOREIGN KEY (`disputeId`) REFERENCES `Dispute`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PlayerMission` ADD CONSTRAINT `PlayerMission_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PlayerMission` ADD CONSTRAINT `PlayerMission_missionId_fkey` FOREIGN KEY (`missionId`) REFERENCES `Mission`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PlayerAchievement` ADD CONSTRAINT `PlayerAchievement_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PlayerAchievement` ADD CONSTRAINT `PlayerAchievement_achievementId_fkey` FOREIGN KEY (`achievementId`) REFERENCES `Achievement`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Vehicle` ADD CONSTRAINT `Vehicle_ownerId_fkey` FOREIGN KEY (`ownerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PublicOffice` ADD CONSTRAINT `PublicOffice_holderId_fkey` FOREIGN KEY (`holderId`) REFERENCES `Player`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `OfficeCandidate` ADD CONSTRAINT `OfficeCandidate_officeId_fkey` FOREIGN KEY (`officeId`) REFERENCES `PublicOffice`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `OfficeCandidate` ADD CONSTRAINT `OfficeCandidate_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `OfficePayment` ADD CONSTRAINT `OfficePayment_officeId_fkey` FOREIGN KEY (`officeId`) REFERENCES `PublicOffice`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `OfficePayment` ADD CONSTRAINT `OfficePayment_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `NeutralZone` ADD CONSTRAINT `NeutralZone_ownerId_fkey` FOREIGN KEY (`ownerId`) REFERENCES `Player`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ZoneStructure` ADD CONSTRAINT `ZoneStructure_zoneId_fkey` FOREIGN KEY (`zoneId`) REFERENCES `NeutralZone`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Unit` ADD CONSTRAINT `Unit_ownerId_fkey` FOREIGN KEY (`ownerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Battle` ADD CONSTRAINT `Battle_attackerId_fkey` FOREIGN KEY (`attackerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Battle` ADD CONSTRAINT `Battle_zoneId_fkey` FOREIGN KEY (`zoneId`) REFERENCES `NeutralZone`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `BattleRound` ADD CONSTRAINT `BattleRound_battleId_fkey` FOREIGN KEY (`battleId`) REFERENCES `Battle`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `WarRankingEntry` ADD CONSTRAINT `WarRankingEntry_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Notification` ADD CONSTRAINT `Notification_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ChatMessage` ADD CONSTRAINT `ChatMessage_channelId_fkey` FOREIGN KEY (`channelId`) REFERENCES `ChatChannel`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ChatMessage` ADD CONSTRAINT `ChatMessage_senderId_fkey` FOREIGN KEY (`senderId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `TerraformContribution` ADD CONSTRAINT `TerraformContribution_playerId_fkey` FOREIGN KEY (`playerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `GagarinBulletin` ADD CONSTRAINT `GagarinBulletin_moonId_fkey` FOREIGN KEY (`moonId`) REFERENCES `Moon`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

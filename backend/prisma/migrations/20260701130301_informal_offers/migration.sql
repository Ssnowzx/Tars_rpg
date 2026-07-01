-- CreateTable
CREATE TABLE `InformalOffer` (
    `id` VARCHAR(191) NOT NULL,
    `sellerId` VARCHAR(191) NOT NULL,
    `giveKey` ENUM('oxygen', 'water', 'biomass', 'energy', 'metalore', 'alloys', 'chemicals', 'biofuel', 'aluminum', 'tin', 'copper', 'silicon', 'lithium', 'tungsten', 'tantalum', 'gold', 'componentBasic', 'componentIntermediate', 'componentAdvanced', 'niobium', 'helium3', 'quartz', 'redIron', 'organicResin', 'methaneIce', 'fossilPlasma', 'bioFungus') NOT NULL,
    `giveQty` INTEGER NOT NULL,
    `wantKey` ENUM('oxygen', 'water', 'biomass', 'energy', 'metalore', 'alloys', 'chemicals', 'biofuel', 'aluminum', 'tin', 'copper', 'silicon', 'lithium', 'tungsten', 'tantalum', 'gold', 'componentBasic', 'componentIntermediate', 'componentAdvanced', 'niobium', 'helium3', 'quartz', 'redIron', 'organicResin', 'methaneIce', 'fossilPlasma', 'bioFungus') NOT NULL,
    `wantQty` INTEGER NOT NULL,
    `distanceSlots` INTEGER NOT NULL DEFAULT 10,
    `deals` INTEGER NOT NULL DEFAULT 0,
    `successRate` INTEGER NOT NULL DEFAULT 100,
    `scams` INTEGER NOT NULL DEFAULT 0,
    `note` TEXT NOT NULL DEFAULT '',
    `status` VARCHAR(191) NOT NULL DEFAULT 'open',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `InformalOffer_sellerId_status_idx`(`sellerId`, `status`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `InformalOffer` ADD CONSTRAINT `InformalOffer_sellerId_fkey` FOREIGN KEY (`sellerId`) REFERENCES `Player`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

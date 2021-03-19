#!/usr/bin/env node

import * as fs from 'fs';
import { defaultEnv, LigoEnv, compileContract} from './ligo';
import { $log } from '@tsed/logger';

type ContractCompiler = (env: LigoEnv) => Promise<void>;

// add other contracts here
const contractCompilers: ContractCompiler[] = 
  [ compileNftFaucetContract
  , compileNftContract
  , compileFixedPriceSaleMarketPlaceContract
  , compileFixedPriceSaleTezMarketPlaceContract
  , compileEnglishAuctionTezContract
  , compileFtFaucetContract
  , compileFtContract
  , compileTicketNftAuctionContract
  , compileTicketNftWalletContract
  ];

async function main(): Promise<void> {
  try {
    const env = defaultEnv;

    await Promise.all(contractCompilers.map(compiler => compiler(env)));

    process.exit(0);
  } catch (err) {
    $log.error(err);
    process.exit(1);
  }
}

async function compileNftFaucetContract(env: LigoEnv): Promise<void> {
  $log.info('compiling NFT faucet contract');
  await await compileContract(
    env,
    'minter_collection/fa2_multi_nft_faucet.mligo',
    'nft_faucet_main',
    'fa2_multi_nft_faucet.tz'
  );
  $log.info('compiled NFT faucet contract');
}

async function compileNftContract(env: LigoEnv): Promise<void> {
  $log.info('compiling NFT contract');
  await await compileContract(
    env,
    'minter_collection/fa2_multi_nft_asset.mligo',
    'nft_asset_main',
    'fa2_multi_nft_asset.tz'
  );
  $log.info('compiled NFT contract');
}


async function compileFtFaucetContract(env: LigoEnv): Promise<void> {
  $log.info('compiling FT faucet contract');
  await await compileContract(
    env,
    'minter_collection/fa2_multi_ft_faucet.mligo',
    'ft_faucet_main',
    'fa2_multi_ft_faucet.tz'
  );
  $log.info('compiled FT faucet contract');
}

async function compileFtContract(env: LigoEnv): Promise<void> {
  $log.info('compiling FT contract');
  await await compileContract(
    env,
    'minter_collection/fa2_multi_ft_asset.mligo',
    'multi_ft_asset_main',
    'fa2_multi_ft_asset.tz'
  );
  $log.info('compiled NFT contract');
}

async function compileFixedPriceSaleMarketPlaceContract(env: LigoEnv): Promise<void> {
    $log.info('compiling fixed price sale marketplace contract');

    await await compileContract(
        env,
        'fixed_price_sale/fixed_price_sale_market.mligo',
        'fixed_price_sale_main',
        'fixed_price_sale_market.tz'
    );
    $log.info('compiled fixed price sale marketplace contract');
}

async function compileFixedPriceSaleTezMarketPlaceContract(env: LigoEnv): Promise<void> {
    $log.info('compiling fixed price sale (sold in tez) marketplace contract');

    await compileContract(
        env,
        'fixed_price_sale/fixed_price_sale_market_tez.mligo',
        'fixed_price_sale_tez_main',
        'fixed_price_sale_market_tez.tz'
    );
    $log.info('compiled fixed price sale (sold in tez) marketplace contract');
}

async function compileEnglishAuctionTezContract(env: LigoEnv): Promise<void> {
  $log.info('compiling english auction tez contract');

  await compileContract(
      env,
      'english_auction/english_auction_tez.mligo',
      'english_auction_tez_main',
      'english_auction_tez.tz'
  );
  $log.info('compiled english auction tez contract');
}

async function compileTicketNftAuctionContract(env: LigoEnv): Promise<void> {
  $log.info('compiling ticket nft auction contract');

  await compileContract(
      env,
      'tickets/nft_auction.mligo',
      'ticket_auction_main',
      'ticket_auction.tz'
  );
  $log.info('compiled ticket nft auction contract');
}

async function compileTicketNftWalletContract(env: LigoEnv): Promise<void> {
  $log.info('compiling ticket nft wallet contract');

  await compileContract(
      env,
      'tickets/nft_wallet.mligo',
      'ticket_wallet_main',
      'ticket_wallet.tz'
  );
  $log.info('compiled ticket nft wallet contract');
}

main();

-- | Lorentz bindings for the english auction (Tez version).
module Lorentz.Contracts.EnglishAuction.Tez where

import Lorentz

import qualified Lorentz.Contracts.AllowlistSimple as AllowlistSimple
import Lorentz.Contracts.MinterSdk
import qualified Lorentz.Contracts.NoAllowlist as NoAllowlist
import Lorentz.Contracts.PausableAdminOption
import Lorentz.Contracts.Spec.FA2Interface
import Michelson.Test.Import (embedContractM)
import qualified Michelson.Typed as T

-- Types
----------------------------------------------------------------------------

newtype AuctionId = AuctionId Natural
  deriving stock (Generic, Eq, Ord)
  deriving newtype (IsoValue, HasAnnotation)

data FA2Token = FA2Token
  { tokenId :: TokenId
  , amount :: Natural
  }

customGeneric "FA2Token" ligoCombLayout
deriving anyclass instance IsoValue FA2Token
deriving anyclass instance HasAnnotation FA2Token

data Tokens = Tokens
  { fa2Address :: Address
  , fa2Batch :: [FA2Token]
  }

customGeneric "Tokens" ligoCombLayout
deriving anyclass instance IsoValue Tokens
deriving anyclass instance HasAnnotation Tokens

data Auction = Auction
  { seller :: Address
  , currentBid :: Mutez
  , startTime :: Timestamp
  , lastBidTime :: Timestamp
  , roundTime  :: Integer
  , extendTime  :: Integer
  , asset :: [Tokens]
  , minRaisePercent :: Natural
  , minRaise :: Mutez
  , endTime :: Timestamp
  , highestBidder :: Address
  }

customGeneric "Auction" ligoCombLayout
deriving anyclass instance IsoValue Auction
deriving anyclass instance HasAnnotation Auction

data ConfigureParam = ConfigureParam
  { openingPrice :: Mutez
  , minRaisePercent :: Natural
  , minRaise :: Mutez
  , roundTime :: Natural
  , extendTime :: Natural
  , asset :: [Tokens]
  , startTime :: Timestamp
  , endTime :: Timestamp
  }

customGeneric "ConfigureParam" ligoCombLayout
deriving anyclass instance IsoValue ConfigureParam
deriving anyclass instance HasAnnotation ConfigureParam

defConfigureParam :: ConfigureParam
defConfigureParam = ConfigureParam
  { openingPrice = toMutez 1
  , minRaisePercent = 1
  , minRaise = toMutez 1
  , roundTime = 100000000000
  , extendTime = 100000000000
  , asset = []
  , startTime = timestampFromSeconds 0
  , endTime = timestampFromSeconds 1000000000000
  }

data AuctionStorage al = AuctionStorage
  { pausableAdmin :: AdminStorage
  , currentId :: Natural
  , maxAuctionTime :: Natural
  , maxConfigToStartTime :: Natural
  , auctions :: BigMap Natural Auction
  , allowlist :: al
  }

customGeneric "AuctionStorage" ligoCombLayout
deriving anyclass instance IsoValue al => IsoValue (AuctionStorage al)
deriving anyclass instance HasAnnotation al => HasAnnotation (AuctionStorage al)

initAuctionStorage :: Monoid al => AdminStorage -> AuctionStorage al
initAuctionStorage as = AuctionStorage
  { pausableAdmin = as
  , currentId = 0
  , maxAuctionTime = 99999999999999999999
  , maxConfigToStartTime = 99999999999999999
  , auctions = mempty
  , allowlist = mempty
  }

data AuctionWithoutConfigureEntrypoints al
  = Bid AuctionId
  | Cancel AuctionId
  | Resolve AuctionId
  | Admin AdminEntrypoints
  | Update_allowed al

customGeneric "AuctionWithoutConfigureEntrypoints" ligoLayout
deriving anyclass instance IsoValue al => IsoValue (AuctionWithoutConfigureEntrypoints al)
deriving anyclass instance HasAnnotation al => HasAnnotation (AuctionWithoutConfigureEntrypoints al)

instance
  ( RequireAllUniqueEntrypoints (AuctionWithoutConfigureEntrypoints al), IsoValue al
  , EntrypointsDerivation EpdDelegate (AuctionWithoutConfigureEntrypoints al)
  ) =>
    ParameterHasEntrypoints (AuctionWithoutConfigureEntrypoints al) where
  type ParameterEntrypointsDerivation (AuctionWithoutConfigureEntrypoints al) = EpdDelegate

data AuctionEntrypoints al
  = Configure ConfigureParam
  | AdminAndInteract (AuctionWithoutConfigureEntrypoints al)

customGeneric "AuctionEntrypoints" ligoLayout
deriving anyclass instance IsoValue al => IsoValue (AuctionEntrypoints al)
deriving anyclass instance HasAnnotation al => HasAnnotation (AuctionEntrypoints al)

instance
  ( RequireAllUniqueEntrypoints (AuctionEntrypoints al), IsoValue al
  , EntrypointsDerivation EpdDelegate (AuctionEntrypoints al)
  ) =>
    ParameterHasEntrypoints (AuctionEntrypoints al) where
  type ParameterEntrypointsDerivation (AuctionEntrypoints al) = EpdDelegate

-- Contract
----------------------------------------------------------------------------

auctionTezContract
  :: T.Contract
      (ToT (AuctionEntrypoints NoAllowlist.Entrypoints))
      (ToT (AuctionStorage NoAllowlist.Allowlist))
auctionTezContract =
  $$(embedContractM (inBinFolder "english_auction_tez.tz"))

auctionTezAllowlistedContract
  :: T.Contract
      (ToT (AuctionEntrypoints AllowlistSimple.Entrypoints))
      (ToT (AuctionStorage AllowlistSimple.Allowlist))
auctionTezAllowlistedContract =
  $$(embedContractM (inBinFolder "english_auction_tez_allowlisted.tz"))

-- Errors
----------------------------------------------------------------------------

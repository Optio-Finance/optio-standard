import os
import logging
import pytest
import pytest_asyncio
from starkware.crypto.signature.signature import (
    get_random_private_key,
    private_to_stark_key,
)
from starkware.starknet.testing.starknet import Starknet
from utils import str_to_felt

ACCOUNT_CONTRACT_FILE = os.path.join(
    os.path.dirname(__file__), "../contracts/account/Account.cairo"
)
CONTRACT_FILE = os.path.join(
    os.path.dirname(__file__), "../contracts/standard/Optio.cairo"
)
logger = logging.getLogger(__name__)


@pytest.fixture
def private_keys():
    buyer_private_key = get_random_private_key()
    seller_private_key = get_random_private_key()
    return buyer_private_key, seller_private_key

@pytest_asyncio.fixture
async def contracts(private_keys):
    # @dev Preparing Optio contract for interacting
    starknet = await Starknet.empty()
    optio_contract = await starknet.deploy(
        source=CONTRACT_FILE,
        constructor_calldata=[
            str_to_felt("Optio"),
            str_to_felt("ETH")
        ],
    )
    # @notice Getting public keys for both parties
    buyer_private_key, seller_private_key = private_keys
    buyer_public_key = private_to_stark_key(buyer_private_key)
    seller_public_key = private_to_stark_key(seller_private_key)

    # @notice Deploying 
    buyer_account_contract = await starknet.deploy(
        source=ACCOUNT_CONTRACT_FILE, constructor_calldata=[buyer_public_key]
    )
    seller_account_contract = await starknet.deploy(
        source=ACCOUNT_CONTRACT_FILE, constructor_calldata=[seller_public_key]
    )
    return (
        optio_contract,
        buyer_account_contract,
        seller_account_contract,
    )

@pytest.mark.asyncio
async def test_deploy(contracts):
    # @dev Checking a buyer's balance, should be zero as newly deployed
    optio_contract, buyer_account_contract, seller_account_contract = contracts
    response = await optio_contract.balanceOf(buyer_account_contract.contract_address, 0, 0).call()
    assert response.result.balance == 0
    return


@pytest.mark.asyncio
async def test_setting_metadata(contracts):
    optio_contract, buyer_account_contract, seller_account_contract = contracts

    # @dev Setting metadata(name=1, type=2, description=3) for class(0, 0)
    # @param class_id The ID of the particular class
    # @param metadata_id The ID of the particular set of metadata
    # @param Metadata Typings for metadata
    await optio_contract.createClassMetadata(0, 0, (0, 0, 1, 2, 3)).invoke(
        caller_address=seller_account_contract.contract_address
    )
    return

@pytest.mark.asyncio
async def test_getting_metadata(contracts):
    optio_contract, buyer_account_contract, seller_account_contract = contracts

    # @dev Setting metadata(name=4, type=5, description=6) for class(0, 1)
    # @param class_id The ID of the particular class
    # @param metadata_id The ID of the particular set of metadata
    # @param Metadata Typings for metadata
    await optio_contract.createClassMetadata(0, 1, (0, 1, 4, 5, 6)).invoke(
        caller_address=seller_account_contract.contract_address
    )
    # @dev Getting the metadata typings for class(0, 0)
    # @param class_id The ID of the particular class
    # @param metadata_id The ID of the particular set of metadata
    reponse = await optio_contract.getClassMetadata(0, 1).call()

    # @dev Asserting equality between set and returned metadata
    metadata = reponse.result.classMetadata
    assert metadata[0] == 0 # class_id
    assert metadata[1] == 1 # metadata_id
    assert metadata[2] == 4 # name
    assert metadata[3] == 5 # type
    assert metadata[4] == 6 # description

    return
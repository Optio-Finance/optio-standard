from script_utils import create_compile_command, run_command

CONTRACTS_TO_COMPILE = [
    # ["optio_pool", "optio_pool"],
    # ["optio_controller","optio_controller"],
    # ["lib/openzeppelin/contracts/token/ERC20_Mintable", "ERC20_Mintable"],
    # ["lib/openzeppelin/contracts/token/ERC721_Mintable_Burnable", "ERC721_Mintable_Burnable"],
    # ["lib/pool/stable", "stable"]
]

for contract in CONTRACTS_TO_COMPILE:
    cmd = create_compile_command(contract[0], contract[1])
    w = run_command(cmd)

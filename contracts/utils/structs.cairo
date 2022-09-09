%lang starknet

struct ClassProps {
    exists: felt,
    creator: felt,
    created: felt,
    latest_unit_id: felt,
    latest_unit_timestamp: felt,
    liquidity: felt,
    total_supply: felt,
}

struct ClassMetadata {
    class_id: felt,
    metadata_id: felt,
    name: felt,
    type: felt,
    description: felt,
}

struct UnitProps {
    id: felt,
    exists: felt,
    creator: felt,
    created: felt,
    prev_unit_id: felt,
}

struct UnitMetadata {
    class_id: felt,
    unit_id: felt,
    metadata_id: felt,
    name: felt,
    type: felt,
    description: felt,
}

struct Values {
    uint: felt,
    string: felt,
    address: felt,
    boolean: felt,
    timestamp: felt,
    uri: felt,
}

struct Class {
    class_id: felt,
    name: felt,
    type: felt,
    description: felt,
    values: Values,
}

struct Unit {
    class_id: felt,
    unit_id: felt,
    class: felt,
    name: felt,
    type: felt,
    description: felt,
    values: Values,
}

struct Transaction {
    class_id: felt,
    unit_id: felt,
    amount: felt,
}

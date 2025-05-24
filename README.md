# Move Integers

## Overview

This repository contains a collection of Move modules implementing various integer sizes. These modules are designed to provide more flexibility in integer operations within Move smart contracts.

## Modules

The following modules are included:

- `i8.move`: 8-bit signed integer operations
- `i16.move`: 16-bit signed integer operations
- `i32.move`: 32-bit signed integer operations
- `i64.move`: 64-bit signed integer operations
- `i128.move`: 128-bit signed integer operations
- `i256.move`: 256-bit signed integer operations

Each module provides basic arithmetic operations and comparisons for its respective integer size.

## Usage

To use these modules in your Move project, you can import them as follows:

```move
use 0xfff1e5bad5901cdb1c6755ece8603b992b3f0000a3e5b96d8d0bdc49d6433fff::i64;
use 0xfff1e5bad5901cdb1c6755ece8603b992b3f0000a3e5b96d8d0bdc49d6433fff::i128;
// ... and so on for other modules
```

## Testing

```
aptos move test
```

## Move Coverage Summary

| Module                                                                 | Coverage (%) |
| ---------------------------------------------------------------------- | ------------ |
| fff1e5bad5901cdb1c6755ece8603b992b3f0000a3e5b96d8d0bdc49d6433fff::i128 | 100.00       |
| fff1e5bad5901cdb1c6755ece8603b992b3f0000a3e5b96d8d0bdc49d6433fff::i16  | 100.00       |
| fff1e5bad5901cdb1c6755ece8603b992b3f0000a3e5b96d8d0bdc49d6433fff::i256 | 100.00       |
| fff1e5bad5901cdb1c6755ece8603b992b3f0000a3e5b96d8d0bdc49d6433fff::i32  | 100.00       |
| fff1e5bad5901cdb1c6755ece8603b992b3f0000a3e5b96d8d0bdc49d6433fff::i64  | 100.00       |
| fff1e5bad5901cdb1c6755ece8603b992b3f0000a3e5b96d8d0bdc49d6433fff::i8   | 100.00       |
| **Overall Move Coverage**                                              | **100.00%**  |

## TODO

- [ ] Make functions inline.
- [ ] Write MSL specs to prove the contract.

## Contributing

Contributions to improve these modules are welcome. Please ensure you add appropriate tests for any new functionality.

## Acknowledgements

This project drew inspiration from the Integer Mate repository by Cetus Protocol. Their work has been a valuable contribution to the Move ecosystem.

## Contributors

<a href="https://github.com/0xAnto"><img src="https://avatars.githubusercontent.com/u/72078695?v=4" width="50" alt="@0xAnto" style="border-radius:50%"></a>
<a href="https://github.com/0xbe1"><img src="https://avatars.githubusercontent.com/u/101405096?v=4" width="50" alt="@0xbe1" style="border-radius:50%"></a>
<a href="https://github.com/ch4r10t33r"><img src="https://avatars.githubusercontent.com/u/1627026?v=4" width="50" alt="@ch4r10t33r" style="border-radius:50%"></a>

## License

This project is licensed under the MIT License. @ Antony Ranjith F

## Audit
Audited by MoveBit.

## Contact

For questions or concerns, you can reach out to the maintainer on Twitter: [@0xAnto](https://twitter.com/0xanto)

Remember to use these modules responsibly and consider a thorough audit before deploying them in any production environment.

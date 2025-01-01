# Move Integers

⚠️ **WARNING: These Move modules has not been audited. Use with caution in production environments. The authors are not responsible for any potential issues or vulnerabilities.** ⚠️

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
use 0xfff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i64;
use 0xfff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i128;
// ... and so on for other modules
```

## Testing

```
aptos move test
```

## Move Coverage Summary

| Module                                                                 | Coverage (%) |
| ---------------------------------------------------------------------- | ------------ |
| fff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i128 | 100.00       |
| fff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i16  | 100.00       |
| fff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i256 | 100.00       |
| fff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i32  | 100.00       |
| fff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i64  | 100.00       |
| fff3b2d7c65b54bd8643cf5b66a7aaf8461d0a533fce0dd88684b0acdc5e3fff::i8   | 100.00       |
| **Overall Move Coverage**                                              | **100.00%**  |

## TODO

- [ ] Make functions inline.
- [ ] Write MSL specs to prove the contract.

## Contributing

Contributions to improve these modules are welcome. Please ensure you add appropriate tests for any new functionality.

## Acknowledgements

This project drew inspiration from the Integer Mate repository by Cetus Protocol. Their work has been a valuable contribution to the Move ecosystem.

## License

This project is licensed under the MIT License.

Antony Ranjith F

## Contact

For questions or concerns, you can reach out to the maintainer on Twitter: [@0xAnto](https://twitter.com/0xanto)

Remember to use these modules responsibly and consider a thorough audit before deploying them in any production environment.

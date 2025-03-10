# QR Blackmarket

## Support https://discord.gg/pNvGMgQ2vZ

![68747470733a2f2f692e6962622e636f2f52706366723948372f312e706e67 (1)|690x388](https://forum-cfx-re.akamaized.net/original/5X/6/2/f/6/62f629ec6f525caadd926e90f37cf360a630d65a.jpeg)

A realistic blackmarket script for QBCore Framework that allows players to order illegal items through a newspaper interface.

## Features

- Realistic newspaper UI for the black market
- Uses the "blackpaper" item to access the market
- Players can browse and order various illegal items
- After placing an order, coordinates are sent to the player's phone
- Random delivery locations with a delivery van
- Integration with qb-target for item collection

## Dependencies

- QBCore Framework
- qb-target (or ox_target)
- qb-phone (for notifications)

## Installation

1. Ensure you have the latest version of QBCore Framework installed
2. Add the "blackpaper" item to your QBCore shared items
3. Copy the `qr-blackmarket` folder to your server resources directory
4. Add `ensure qr-blackmarket` to your server.cfg
5. Restart your server

## Usage

1. Obtain a "blackpaper" item in-game
2. Use the item to open the black market newspaper
3. Browse available items and place an order
4. Wait for coordinates to be sent to your phone
5. Travel to the marked location
6. Use qb-target on the van to collect your items

## Configuration

You can modify the following in the `config.lua` file:

- Delivery locations
- Available black market items
- Price ranges
- Vehicle model for delivery

## Credits

Created by QR Development

<div align="center">
    <img src="https://i.ibb.co/dWGyF4m/flutter-ldk-cover.png" alt="Tutorial Logo"/>
    <h1> How to develop a Non-Custodial Bitcoin Lightning Wallet using Flutter and LDK?</h1>
</div>

Hello everyone! My name is Aniket (aka Anipy) and in this tutorial, I'm going to show you how to create your very own Non-Custodial Bitcoin Lightning wallet using Flutter and the Lightning Development Kit (LDK). It all began for me when I finished reading "Mastering the Lightning Network" book. As a little side project, I decided to develop a non-custodial Bitcoin Lightning wallet, and here's what I've learned and developed along the way.

In this tutorial, I'll share my experiences and provide answers to some of the questions and challenges I encountered while developing the wallet. I received plenty of help from the friendly LDK team developers on their Discord channel, and I'll do my best to explain everything in a straightforward manner. Just a heads up, we won't be diving too deep into UI development or Flutter here; our main focus will be on implementing a Lightning wallet in Flutter with LDK.

If you're already familiar with the Lightning Network, Lightning nodes, and Lightning wallets, feel free to jump right into the "Getting Started" section below. For those of you looking for a quick refresher or wanting to explore this fascinating technology from the ground up, read on for a brief overview.

## What is Lightning Network?
Let's discuss the Lightning Network in simple terms. It's like a protocol built on top of Bitcoin that makes transactions faster, more private, and scalable.

In 2015, Joseph Poon and Thaddeus Dryja proposed the Lightning Network to address Bitcoin's scalability issue.

Think of the Lightning Network as a helpful tool that acts as a second layer technology by enabling off-chain transactions, it reduces the load on the main bitcoin blockchain and allow faster and more cost-effective microtransactions.

Users initially load Bitcoin onto the Lightning Network. They settle on-chain only when they open or close channels (we'll cover this shortly). After that, payments within an open channel can be almost instant, without requiring confirmation from Bitcoin blocks.

The Lightning Network has some cool features:
- Payments on the Lightning Network do not require waiting for block confirmations.
- Lightning Network payments are transmitted between pairs of nodes, offering enhanced privacy compared to on-chain transactions.
- Unlike Bitcoin network transactions, Lightning Network payments do not need permanent storage, reducing resource usage and cost.
- Nodes involved in routing payments are aware only of their predecessor and successor in the payment route.
- The Lightning Network utilizes real bitcoin, maintaining user custody and full control over funds.

So, remember that the Lightning Network is not a separate token or coin; it's built on top of Bitcoin. In the next section we'll talk about Lightning node.

## What is Lightning Node?
The Lightning Network operates through software apps that implement the Lightning Network protocol and most of these apps follow common standards outlined in the [BOLTs](https://github.com/lightning/bolts/tree/master) specification.

A Lightning Network node (LN node) is a piece of software with these key characteristics:
- It serves as a wallet for payments on both the Lightning and Bitcoin network.
- It communicates directly with other nodes, forming the network through peer-to-peer connections.
- It needs access to the Bitcoin blockchain for payment security.

Users have the highest level of control when they run their own Bitcoin node and Lightning node. However, Lightning nodes can also use a lightweight Bitcoin client to interact with the Bitcoin blockchain.

Now in the next section let's talk about Lightning wallet.

## What is Lightning Wallet?
The term "Lightning wallet" can be a bit unclear because it can refer to a combination of various components with some user interface. The most common components found in Lightning wallet software include:

- A keystore that holds secrets, such as wallet mnemonic.
- An LN node (Lightning node) that communicates on the peer-to-peer network, as we discussed earlier.
- A Bitcoin node that stores blockchain data and communicates with other Bitcoin nodes
- A database that maps out nodes and channels announced on the Lightning Network.
- A channel manager that can open and close LN channels
- A close-up system that can find a path of connected channels from payment source to payment destination.

A Lightning wallet may contain all of these functions, acting as a "full" wallet, with no reliance on any third-party services. Or one or more of these components may rely (partially or entirely) on third-party services that mediate those functions.

A key distinction (pun intended) is whether the keystore function is internal or outsourced. In blockchains, control of keys determines custody of funds, as memorialized by the phrase "*your keys, your coins; not your keys, not your coins*".

Custodial wallets outsource key management, while noncustodial wallets put you in control of your own keys.

The wallet you'll learn to create in this tutorial is a noncustodial wallet. This means the user of our wallet will have full control over their keys.

The term "noncustodial wallet" implies that the keystore is local and under the user's control. However, some of the other wallet components may or may not rely on trusted third parties.

Remember that, control over keys is a critical consideration when choosing a Lightning wallet.

Now that you understand the Lightning Network and its key parts, let's jump in and start making your very own Lightning wallet. Get ready for an exciting journey!

## Getting started
Before we get our hands dirty with code, let's kick things off by grabbing the "**starter**" project for this tutorial. Just copy and paste the following command into your terminal:

```bash
git clone -b starter --single-branch https://github.com/aniketambore/bijli_ln_wallet
```

This command will get you the "**starter**" project in no time and will save your time.

Feeling the excitement? Great! Now, fire up your favorite code editor, whether it's VS Code or Android Studio. After that, run `flutter pub get` to set things up, and then launch the app. Right now, it's a straightforward UI project, but we'll soon weave in some Lightning Network magic.

![Wallet Creation Screen](https://i.ibb.co/5LZd7RH/wallet-creation-ss-1.png)

## Project files
There are some files in the **starter** project to help you out. Before you learn how to develop a non-custodial bitcoin lightning wallet, take a look at them.

### Assets folder
Inside the **assets** directory, you'll find images that will be used to build your app.

![Assets Folder](https://i.ibb.co/jwY0v67/assets-folder.png)

## Folder Structure
In the **lib** directory, you'll notice various folders, each serving a specific purpose:

![lib Folder](https://i.ibb.co/SBKfxXY/lib-folder.png)

### Component Library Folder
**lib/component_library** contains all the UI components that either are, or have the potential to be, reused across different screens.

### Domain Models Folder
**lib/domain_models** contains all the model objects used in our app. These models define how data is structured and managed within the app.

### Features Folder
**lib/features** contains the core functionality of the app, following a _package-by-feature_ approach. It's where the magic happens.

I consider a feature to be either:
1. A screen
2. A dialog that excutes I/O calls. The **lib/features/send_offchain_dialog** falls into this category.

### Wallet Repository Folder
**lib/wallet_repository** is where the communication with the LDK (Lightning Development Kit) Node Flutter plugin happens. This repository coordinates data from different sources and keeps things running smoothly.

## App libraries
The **starter** project comes with a set of useful libraries listed in `pubspec.yaml`:

```yaml
dependencies:
  ...
  bitcoin_ui_kit:
    git:
      url: https://github.com/aniketambore/bitcoinuikit-flutter.git
      ref: alternative-implementation
  bitcoin_icons: ^0.0.4
  ldk_node: ^0.1.2
  bolt11_decoder: ^1.0.2
  bip39: ^1.0.6
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.0.12
  qr_flutter: ^4.1.0
  share_plus: ^7.1.0
  another_flushbar: ^1.12.30
  floating_action_bubble: ^1.1.4
  equatable: ^2.0.5
  auto_size_text: ^3.0.0
  routemaster: ^1.0.1
  flutter_bloc: ^8.1.3
  confetti: ^0.7.0
  rxdart: ^0.27.7
```

Here's what they help you to do:

- `bitcoin_ui_kit`: This package offers helpful widgets and themes following the [Bitcoin design guide](https://bitcoin.design/guide/). It's like a design toolbox,

- `bitcoin_icons`: Use this package to easily access the collections of [Bitcoin icons](https://bitcoinicons.com/) for your app.

- `ldk_node`: This package provides a simple interface for setting up and running a Lightning node with an integrated on-chain wallet.

- `bolt11_decoder`: Use this package to decode BOLT11 invoices.

- `bip39`: This package helps generate new mnemonic phrases. It's like a phrase generator.

- `flutter_secure_storage`: This package ensures secure storage capabilities for your app. It's your secret vault for mnemonic.

- `path_provider`: This package helps you access the file system path on the device.

- `qr_flutter`: This package enables you to generate QR codes within your app.

- `share_plus`: This package allows easy sharing of content from our app.

- `another_flushbar`: This package provides customizable and user-friendly notifications.

- `floating_action_bubble`: This package helps us to create floating action buttons with a bubble effect.

- `equatable`: This package simplifies equality comparisons for our Dart classes.

- `auto_size_text`: This package automatically adjusts the text size to fit the available space.

- `routemaster`: This package offers a flexible routing system.

- `flutter_bloc`: This package is used to implement the BLoC (Business Logic Component) design pattern in our app.

- `confetti`: This package adds confetti animations to our app.

- `rxdart`: This package extends the capabilities of Dart's Streams with reactive programming.

## Wallet Initialization
In this step, we'll set up our wallet, starting with some crucial configurations. Open **lib/wallet_repository/src/wallet_repository.dart** and follow these instructions:

### Import the Necessary Packages
Locate `// TODO: Add imports here` and replace it with the following code:

```dart
import 'package:ldk_node/ldk_node.dart' as ldk;
import 'package:bip39/bip39.dart' as bip39;
import 'package:path_provider/path_provider.dart';
```
Here we're importing the `ldk_node` plugin and `bip39` and `path_provider` package, giving alias "**ldk**" and "**bip39**" is for easier reference in your code.

### Initialize Wallet Configuration
Move on to `// TODO: Initialize variables here` and replace it with the following code:

```dart
  // 1
  static const LDK_NODE_DIR = "LDK_NODE";
  // 2
  static const esploraURL = "https://mempool.space/testnet/api";
  // 3
  static const network = ldk.Network.testnet;
  // 4
  late ldk.Node ldkNode;
```

Here we're defining configuration variables for LDK:

1. `LDK_NODE_DIR`: Defines the directory where your LDK node's data will be stored.

2. `esploraURL`: This URL points to a Bitcoin testnet server (specifically, mempool.space) used for indexing blockchain data quickly.

3. `network`: Indicates that the network being used is the Bitcoin testnet. Options avialable are [Bitcoin, Testnet, Signet, Regtest]

4. `ldkNode`: The `ldkNode` variable will hold the instance of the LDK node that will be set up below for interacting with the Lightning Network.

### Generate a New Mnemonic
Locate `// TODO: Implement method to generate a new mnemonic` and replace it with the following code:

```dart
  String _generateMnemonic() {
    // 1
    final mnemonic = bip39.generateMnemonic();
    // 2
    return mnemonic;
  }
```

In the above code, we're:
1. Generating a new mnemonic using the `bip39` package.
2. Returning the generated mnemonic for wallet setup.

### Create or Recover a Wallet
Now, locate `// TODO: Implement method to create or recover a wallet` and replace it with the following code:

```dart
  Future<String> createOrRecoverWallet({String? recoveryMnemonic}) async {
    // 1
    final mnemonic = recoveryMnemonic ?? _generateMnemonic();
    // 2
    final directory = await getApplicationDocumentsDirectory();
    // 3
    final storagePath = "${directory.path}/$LDK_NODE_DIR";
    // 4
    final builder = ldk.Builder()
        .setEntropyBip39Mnemonic(mnemonic: ldk.Mnemonic(mnemonic))
        .setNetwork(network)
        .setStorageDirPath(storagePath)
        .setEsploraServer(esploraServerUrl: WalletRepository.esploraURL);
    // 5
    ldkNode = await builder.build();
    // 6
    await ldkNode.start();
    // 7
    await _secureStorage.upsertWalletMnemonic(
      mnemonic: mnemonic,
    );
    // 8
    return mnemonic;
  }
```

In this section, you are:
1. Deciding whether to create a new wallet or recover an existing one.
2. Getting the application's document directory for data storage.
3. Defining the storage path for the LDK node's data.
4. Setting up the LDK node with the specified configuration using the builder.
5. Building the LDK node based on the provided configuration.
6. Starting the LDK node for network interaction.
7. Securely storing the mnemonic for future use.
8. Returning the mnemonic, which is essential for wallet management.

### Retrieve Wallet Information
Now, let's locate `// TODO: Implement method to retrieve wallet mnemonic from storage` and replace it with this code:

```dart
  Future<String?> getWalletMnemonic() {
    return _secureStorage.getWalletMnemonic();
  }
```
Here we're retrieving the wallet's mnemonic from secure storage and returning it.

### Get Lightning Node ID
Now, let's locate `// TODO: Implement method to retrieve Lightning node ID` and replace it with this code:

```dart
  Future<String> getNodeId() async {
    final id = await ldkNode.nodeId();
    return id.internal;
  }
```
Here, you're retrieving your wallet LDK node's ID and returning it as a string.

Now, in the `_getWalletInformation()` method locate `// TODO: Retrieve our own node ID` and replace it with the following code:

```dart
String nodeId = await getNodeId();
```

In the `Wallet` object, replace `nodeId: 'dummy_node_id'` with `nodeId: nodeId`, `esploraUrl: 'dummy_esplora_url'` with `esploraUrl: esploraURL`, and `network: 'dummy_network'` with `network: network.name`.

Let's test the app! If it's already running, perform a hot reload and click the "*Create Wallet*" button.

![Wallet Creation To Home Screen](https://i.ibb.co/YXWffmr/wallet-creation-to-home-ss-2.png)

Now, you'll be on the home screen. To view your mnemonic and node ID, click the popup menu button in the app's toolbar and select "*Wallet Info*."

The Wallet Information screen will appear, displaying your wallet information. Click on "*Display Mnemonic*" and a dialog will pop up, revealing your wallet mnemonic as:

![Wallet Information and Mnemonic Dialog](https://i.ibb.co/rkhSdL6/wallet-info-mnemonic-display-ss-3.png)

In the next section, we'll focus on implementing Bitcoin on-chain functionality in our app.

## On-Chain Functionality
In this section we'll implement some essential functions for on-chain Bitcoin transactions. Let's dive into it:

### Retrieve On-Chain Address
To get your Bitcoin on-chain address, locate `// TODO: Implement method to retrieve on-chain address` and replace it with the following code:

```dart
  Future<String> getOnChainAddress() async {
    final ldk.Address address = await ldkNode.newOnchainAddress();
    return address.internal;
  }
```
The `getOnChainAddress` method requests a new Bitcoin on-chain address from the LDK Node and returns it as a string. This address is crucial for receiving on-chain Bitcoin transactions.

### Retrieve On-Chain Balance
Next, replace `// TODO: Implement method to retrieve on-chain balance` with this code:

```dart
  Future<int> getOnChainBalance() async {
    // 1
    await ldkNode.syncWallets();
    // 2
    final balance = await ldkNode.totalOnchainBalanceSats();
    return balance;
  }
```

In this code, we're performing the following steps:
1. Synchronizing the wallet to ensure up-to-date balance information.
2. Retrieving and returning the total Bitcoin on-chain balance in sats. This balance represents the amount of Bitcoin you have in your on-chain wallet.

Now, In the `_getWalletInformation()` method locate `// TODO: Retrieve on-chain balance and address information` and replace it with the following code:

```dart
    int onChainBalanceSats = await getOnChainBalance();
    String onChainAddress = await getOnChainAddress();
```

This code retrieves both the on-chain balance and address, ensuring that your wallet's information is up to date.

In the `Wallet` object replace `onChainBalanceSats: 0` with `onChainBalanceSats: onChainBalanceSats` and `onChainAddress: 'dummy_address'` with `onChainAddress: onChainAddress`.

Once you've made these updates, perform a hot reload of your app. Afterward, click the refresh icon on the home screen, situated in the row with the balance view.

After the refresh is complete, you'll see your Bitcoin on-chain address displayed, replacing '*dummy_address*'. The QR code will also be encoded with this Bitcoin on-chain address.

![Bitcoin On-Chain Address Display](https://i.ibb.co/J7VKH4c/bitcoin-onchain-address-ss-4.png)

Now, let's proceed to send some testnet Bitcoin (tBTC) to that address. 

You can get some tBTC to play with from a testnet bitcoin faucet, which gives out free tBTC on demand. Here are a few testnet faucets to get you started:
- https://coinfaucet.eu/en/btc-testnet/
- https://bitcoinfaucet.uo1.net/
- https://testnet-faucet.com/btc-testnet/
- https://kuttler.eu/en/bitcoin/btc/faucet/

![Bitcoin On-Chain Balance Received](https://i.ibb.co/4KRrytS/bitcoin-onchain-balance-received-ss-5.png)

So here with testnet bitcoin, we're not risking real funds. So it's good!

Now, let's implement the functionality to send on-chain Bitcoin.

### Send On-Chain Bitcoin
Locate `// TODO: Implement method to send funds to an on-chain address` and replace it with the following code:

```dart
  Future<String> sendToOnchainAddress({
    required String address,
    required int amountSats,
  }) async {
    // 1
    final addr = ldk.Address(internal: address);
    // 2
    final txid = await ldkNode.sendToOnchainAddress(
      address: addr,
      amountSats: amountSats,
    );
    print('[WalletRepository] Send On-Chain Txid: ${txid.internal}');
    // 3
    return txid.internal;
  }
```

In the code above, you're doing the following:
1. Creating an `Address` object with the provided recipient's on-chain Bitcoin address.
2. Initiating an on-chain transaction to send the specified amount of sats to the address.
3. Returning the transaction ID (txid) for reference.

Now, perform a hot reload of your app, navigate to the **Payments** tab on the home screen, click the floating action button, and choose '**SEND TO BTC ADDRESS**' Enter the recipient's on-chain Bitcoin address and the amount in sats.

Add testnet bitcoin on-chain address in their, if you don't have any bitcoin testnet address just do one thing, send me some tBTC here `tb1qyvp29ysl00rqrayyh633fgmdqsqsucwtnaw9n5` 🙃. Also specify the amount that you want to send in sats. Click on submit.

![Send On-Chain](https://i.ibb.co/fdYr9Nw/bitcoin-send-onchain-ss6.png)

After the payment is successful, you'll see a success indicator screen, and the transaction ID (txid) will be displayed on the console. You can copy this txid and paste it into a block explorer like https://mempool.space/testnet to view your transaction details.

One thing to note is that the current LDK Node Flutter plugin does not provide functionality for:
1. Retrieving Bitcoin on-chain transaction information. (Issue: https://github.com/LtbLightning/ldk-node-flutter/issues/23)
2. Setting a custom fee rate in the sendToOnchainAddress method. (Issue: https://github.com/LtbLightning/ldk-node-flutter/issues/24)

I'll update this section once these issues are resolved. In the next section, we'll dive into setting up payment channels 🚀

## Opening Payment Channel
Let's kick things off by understanding what a payment channel is, but don't worry; we'll keep it simple. In simple terms, a payment channel is like a financial relationship between two Lightning nodes. It's established by funding a 2-of-2 multisignature address from the two channel partners.

So, payment channels are built on top of 2-of-2 multisignature addresses.

In summary, a multisignature address is where bitcoin is locked so that it requires multiple signatures to unlock and spend. In a 2-of-2 multisignature address, as used in the Lightning Network, there are two participating signers and both need to sign to spend the funds.

To open a payment channel, we first need to establish a connection with another node. To do that, we require a "**Node Identifier**" for that node. A Node Identifier typically looks like "**NODEID@Address:Port**"

- The **NODEID** is a unique identifier for a specific node, often presented in hexadecimal encoding.
- The **Address:Port** is a network address identifier where the node can be reached. This can be in various formats, like TCP/IP (IPv4 or IPv6 address with a TCP port number) or TCP/Tor (a Tor "onion" address with a TCP port number).

For example, the **Node Identifier** for the [PLEBNET.DEV testnet lightning node](https://mempool.space/testnet/lightning/node/03ba00a57cec1cef4873065ad54d0912696274cc53155b29a3b1256720e33a0943) looks like this: `03ba00a57cec1cef4873065ad54d0912696274cc53155b29a3b1256720e33a0943@24.199.122.244:19735`. You can often find the identifier encoded in a QR code for easy scanning and connecting.

Keep in mind that to open a payment channel, you need the Node Identifier, which includes nodeId, address/host, and port. Also, you need to specify the channel amount, which is the total channel capacity.

**Here's a pro tip**: You can choose to push/send an amount to your channel partner during channel funding. This helps balance the channel right from the start and allows you to receive payments right away. **But be careful when setting this value because it essentially sends money to your channel partner**.

So before constructing the payment channel we must first be connected with our channel peer to which we want to open a payment channel with. The good news is, LDK offers a convenient method called `connectOpenChannel` to connect to a node and open a new channel. It also handles disconnects and reconnections automatically.

Let's get our hands dirty by implementing the method to open a Lightning payment channel. Find the `// TODO: Implement method to open a Lightning payment channel` and replace it with this code:

```dart
  Future<void> openPaymentChannel({
    required String nodeId,
    required String host,
    required int port,
    required int amountSat,
    int? pushToCounterpartySat,
  }) async {
    await ldkNode.connectOpenChannel(
      netaddress: ldk.NetAddress.iPv4(
        addr: host,
        port: port,
      ),
      nodeId: ldk.PublicKey(internal: nodeId),
      channelAmountSats: amountSat,
      announceChannel: true,
      pushToCounterpartyMsat: (pushToCounterpartySat != null)
          ? satoshisToMilliSatoshis(pushToCounterpartySat)
          : 0,
    );
  }
```

This `openPaymentChannel` method lets you establish a payment channel with a specific node, connect to it, and optionally announce the channel to the network. You can also specify an optional amount to push to your channel partner.

But that's not all. We also need a way to list all the payment channels we've opened. Replace `// TODO: Implement method to list Lightning payment channels` with this code:

```dart
  Future<List<ldk.ChannelDetails>> listPaymentChannels() async {
    final channels = await ldkNode.listChannels();
    return channels;
  }
```

This `listPaymentChannels` method is used to retrieve and return a list of payment channels associated with your wallet.

And, we're not done yet! To keep you in the loop, let's implement getting the list of connected peers. Replace `// TODO: Implement method to list Lightning peers` with this code:

```dart
  Future<List<ldk.PeerDetails>> listPeers() async {
    final peers = await ldkNode.listPeers();
    return peers;
  }
```

The `listPeers` method fetches and returns a list of peer details, representing the peers connected on the Lightning Network to our node.

Finally, let's implement getting all the transaction information by replacing `// TODO: Implement method to list Lightning transactions` with the following code:

```dart
  Future<List<ldk.PaymentDetails>> listTransactions() async {
    // 1
    final paymentDetails = <ldk.PaymentDetails>[];
    // 2
    final payments = await ldkNode.listPayments();
    // 3
    for (var e in payments) {
      if (e.status == ldk.PaymentStatus.succeeded) {
        paymentDetails.add(e);
      }
    }
    // 4
    return paymentDetails;
  }
```

In the code above, we're doing the following:
1. Initializing a list to store payment details.
2. Retrieving a list of all payments made through your wallet.
3. Filtering and adding successful payments to the list of payment details.
4. Returning the list of successful payment details.

Now, head over to the `_getWalletInformation()` method and replace `// TODO: Retrieve lists of payment channels, peers, and payment details` with this code:

```dart
    List<ldk.ChannelDetails> paymentChannelsList = await listPaymentChannels();
    List<ldk.PeerDetails> peersList = await listPeers();
    List<ldk.PaymentDetails> paymentList = await listTransactions();
```

Next, locate `// TODO: Initialize variables to hold various wallet information` and replace it with the following:

```dart
    int inboundCapacitySats = 0;
    int outboundCapacitySats = 0;
    String? bolt11Invoice;
```

Next, locate `// TODO: Calculate inbound and outbound channel capacities` and replace it with this:

```dart
    for (var channel in paymentChannelsList) {
      inboundCapacitySats +=
          milliSatoshisToSatoshis(channel.inboundCapacityMsat);
      outboundCapacitySats +=
          milliSatoshisToSatoshis(channel.outboundCapacityMsat);
    }
```

In the `Wallet` object, replace `inboundCapacitySats: 0` with `inboundCapacitySats: inboundCapacitySats`, `outboundCapacitySats: 0` with `outboundCapacitySats: outboundCapacitySats`, `paymentChannelsList: const []` with `paymentChannelsList: paymentChannelsList`, `peersList: const []` with `peersList: peersList` and `paymentsList: const []` with `paymentsList: paymentList`.

Now, perform a hot reload of your app and run it. Refresh the app by clicking the refresh icon on home screen. To open a payment channel, follow these steps:
1. Go to the "**Channels**" tab.
2. Click on the floating action button and select "**ENTER A NODE URI**" to open the `OpenChannelScreen`.
3. Enter the node ID, address, port, amount, and counterparty amount.
4. Click "**submit**."

So, we'll be opening a payment channel with the [PLEBNET.DEV testnet Lightning node](https://mempool.space/testnet/lightning/node/03ba00a57cec1cef4873065ad54d0912696274cc53155b29a3b1256720e33a0943) using its node identifier: "`03ba00a57cec1cef4873065ad54d0912696274cc53155b29a3b1256720e33a0943@24.199.122.244:19735`".

If everything goes as planned, you'll see a success screen.

![Opening Payment Channel](https://i.ibb.co/DbYBFzQ/opening-payment-channel-ss7.png)

Clicking "**okay**" will take you back to the home screen, where you can see that you now have an open channel with 100,000 sats of capacity, 49,000 sats outbound capacity, and 49,000 sats inbound capacity. The rest is the Bitcoin on-chain fees for opening a payment channel by funding a 2-of-2 multisignature address, which is recorded on the Bitcoin blockchain.

![Channels Tab](https://i.ibb.co/Fgj6SL3/channels-tab-ss-8.png)

Now, let's refresh the wallet, and you'll see the status of your channel. You may need to wait a bit for the funding transaction to be recorded on the Bitcoin blockchain, similar to waiting for confirmations when acquiring Bitcoin from a faucet.

To check if our channel is ready for action, look at the icon next to the list tile, showing the number of confirmations needed for the channel to be usable.

![Channel Ready](https://i.ibb.co/5vJSMTw/channel-ready-ss9.png)

If you see a circle checkmark icon, that means your channel with the [PLEBNET.DEV testnet Lightning node](https://mempool.space/testnet/lightning/node/03ba00a57cec1cef4873065ad54d0912696274cc53155b29a3b1256720e33a0943) is open, funded, and ready for action!

Also, to take a look at your connected node peers. To do that, click on the pop-up menu button in the app bar, then click "Wallet Info" and select "List Channel Peers." This will display a dialog with all the connected peers to our node.

![Wallet Info and Node Peers](https://i.ibb.co/PzJLWTn/wallet-info-node-peer-dialog-ss-10.png)

## Creating BOLT11 Invoice
Most payments on the Lightning Network start with an invoice, generated by the recipient of the payment.

An invoice is a simple payment instruction containing information such as a unique payment identifier (payment hash), amount, and optional text description.

The payment hash is the most important part of the invoice, allowing the payment to travel across multiple channels atomically.

Invoices are typically communicated "out of band," using methods like QR codes, email, or text messages. It would be cool to integrate a peer-to-peer messaging feature using Nostr, but for now, let's stick to creating an invoice.

Now, find `// TODO: Implement method to create a BOLT11 invoice` and replace it with the following code:

```dart
  Future<String> createInvoice({
    required int amountSat,
    String? description,
  }) async {
    // 1
    final invoice = await ldkNode.receivePayment(
      amountMsat: amountSat * 1000,
      // 2
      description: (description != null && description.trim().isNotEmpty)
          ? description
          : 'Bijli Invoice',
      // 3
      expirySecs: 10000,
    );
    // 4
    return invoice.internal;
  }
```

Here's the breakdown of what this code does:

1. Create an invoice to receive a payment with the specified amount.
2. Set the invoice description or use a default if not provided.
3. Set the expiration time for the invoice (in seconds).
4. Return the internal representation of the created invoice as a string.

LDK also provides an option for creating a zero-sats invoice. This type of invoice is used when you want to request and receive a payment without specifying the amount; the sender determines the amount. To implement this, locate `// TODO: Implement method to create a zero-sat BOLT11 invoice` and replace it with this code:

```dart
  Future<String> createZeroSatInvoice({String? description}) async {
    // 1
    final invoice = await ldkNode.receiveVariableAmountPayment(
      nodeId: await ldkNode.nodeId(),
      // 2
      description: (description != null && description.trim().isNotEmpty)
          ? description
          : 'Bijli Invoice',
      // 3
      expirySecs: 10000,
    );
    // 4
    return invoice.internal;
  }
```

In this code:

1. Created a zero-sat invoice to receive a variable amount payment
2. Set the invoice description or use a default if not provided.
3. Set the expiration time for the invoice (in seconds).
4. Return the internal representation of the created invoice as a string.

Moving on to the `_getWalletInformation()` method, locate `// TODO: If there are inbound capacity, create a zero-satoshis invoice (BOLT11 format).` and replace it with:

```dart
    if (inboundCapacitySats != 0) {
      bolt11Invoice = await createZeroSatInvoice();
    }
```

**Just a quick note**: `inboundCapacitySats` is the amount that you're allowed to receive on the Lightning Network. If you don't have any inbound capacity, you can't receive on Lightning. To balance inbound and outbound capacity, nodes should open channels to others and encourage others to open channels to their node.

When we opened a payment channel in the ![Opening Payment Channel](#opening-payment-channel) section we opened the payment channel with capacity of 100,000 sats and we had also pushed 50,000 sats to our channel partner, which means we've inbound capacity of 50,000 sats and outbound capacity of 50,000 sats. Therefore we can receive upto 50,000 sats and can send upto 50,000 sats on lightning.

Now, in the `Wallet` object, replace `bolt11Invoice: 'dummy_invoice'` with `bolt11Invoice: bolt11Invoice`.

Give your app a hot reload and click on the refresh icon on the home screen. Then head to the "**Receive**" tab and click on child the "**LIGHTNING**" tab.

![Zero-sat Invoice](https://i.ibb.co/0f9SGLs/creating-invoice-ss-11.png)

The invoice displayed there is a zero-sats invoice with a default description. If you want to customize this invoice, click on the "**EDIT REQUEST**" button, and a dialog will pop up. Enter the description and the amount in sats.

![Creating Invoice](https://i.ibb.co/P48kYhZ/creating-invoice-ss-12.png)

Now, give it a go by paying this invoice with a different Lightning testnet wallet. You can download the [Eclair Mobile Testnet wallet](https://play.google.com/store/apps/details?id=fr.acinq.eclair.wallet) from the Play Store, for example. In Eclair, grab some tBTC from a faucet, open a payment channel with the same [PLEBNET.DEV testnet Lightning node](https://mempool.space/testnet/lightning/node/03ba00a57cec1cef4873065ad54d0912696274cc53155b29a3b1256720e33a0943), and then try to pay this invoice from the Eclair wallet.

![Paying from Eclair](https://i.ibb.co/D1YRs57/eclair-paying-ss-13.png)

Once the payment goes through in Eclair, click on the refresh icon in "Bijli," and when the refreshing is complete, switch to the "**Payments**" tab. You'll see a ListTile with payment information, which means you successfully received sats on Lightning! ⚡

![Payments Tab](https://i.ibb.co/8Mcvndd/payments-tab-ss-14.png)

This is where the Lightning Network shines, enabling quick and hassle-free payments without the need to wait for confirmations. Now, let's move on to learning how to pay a BOLT11 invoice.

## Paying an invoice
In the previous section, we learned how to create an invoice and paid it from an external wallet. Now, it's time to pay an invoice from our wallet that was generated by the Eclair wallet.

Locate `// TODO: Implement method to send an off-chain Lightning payment` and replace it with the following code:

```dart
  Future<ldk.PaymentStatus> sendOffChainPayment({
    required String bolt11Invoice,
  }) async {
    // 1
    final paymentHash = await ldkNode.sendPayment(
      invoice: ldk.Bolt11Invoice(
        internal: bolt11Invoice,
      ),
    );
    // 2
    final result = await ldkNode.payment(paymentHash: paymentHash);
    // 3
    return result!.status;
  }
```

Here's what this code does:
1. It sends a Bitcoin Lightning payment using the specified BOLT11 invoice.
2. It retrieves the payment details using the payment hash.
3. It returns the status of the payment, indicating whether it was successful, pending, or failed.

Now, perform a hot reload of your app. In the "**Payments**" tab, click on the floating action button, then select "**PASTE AN INVOICE**". This will open the `SendOffChainScreen`. Paste the invoice generated by the Eclair wallet.

![Paste Invoice Screen](https://i.ibb.co/PDcvmCy/paste-invoice-screen-ss-14.png)

Click "continue," and you'll see a dialog displaying the invoice details, including the requested amount and description.

![SendOffChain Dialog](https://i.ibb.co/DkQ6P0x/invoice-decode-dialog-ss-15.png)

Click "**Approve**" in the dialog, and when the payment is successful, you'll see the "Success Indicator" screen.

Click "**okay**" on the success screen, and you'll return to the home screen. Check the transaction information in the "**Payments**" tab.

![Payments Tab](https://i.ibb.co/Qm5RKzV/payments-tab-16.png)

That's how you pay an invoice and manage your Lightning wallet with ease. Enjoy the power of Lightning Network! ⚡

## Payment Delivery
To make a payment on the Lightning Network, the recipient must first create an invoice to receive the payment. This invoice encodes essential information, including a unique payment identifier (payment hash), the payment amount, and an optional text description.

The payment hash within the invoice plays a crucial role by enabling the payment to be routed across multiple channels. This means that payments can be made even when there's no direct payment channel between the sender and the recipient.

In our example, we don't have a direct payment channel with the Eclair Lightning wallet. However, we do share a payment channel with the PLEBNET.DEV Lightning node. The Eclair wallet also has a payment channel with the same PLEBNET.DEV Lightning node. Therefore, when we send or receive funds to and from the Eclair wallet, we're effectively routing our payment through the PLEBNET.DEV Lightning node.

So far, we've covered sending and receiving on-chain transactions, opening payment channels, and sending and receiving funds on the Lightning Network. In the next section, we'll explore how to close a payment channel.

## Closing a payment channel
In the Lightning Network, closing a payment channel may come with on-chain transaction fees. Therefore, it's generally advisable to keep channels open for as long as possible. Rebalancing the channel allows for continued use and an unlimited number of payments.

However, there are situations where closing a channel is necessary. This can include reducing the balance for security reasons or when the channel partner becomes unresponsive.

To implement channel closing in our wallet, locate `// TODO: Implement method to close a Lightning payment channel` and replace it with the following code:

```dart
  Future<void> closePaymentChannel({
    required ldk.ChannelId channelId,
    required ldk.PublicKey nodeId,
  }) async {
    await ldkNode.closeChannel(
      channelId: channelId,
      counterpartyNodeId: nodeId,
    );
  }
```

The `closePaymentChannel` method is used to close a payment channel with the specified channel ID and counterparty node ID.

Now, just perform a hot reload of the app. Go to the "**Channels**" tab, and click on "**CLOSE**" on the channel's ListTile. A dialog will pop up for confirmation. Click "**YES**" there, and when the channel is closed, you'll see the success screen displaying the channel ID that was closed.

![Closing Channel](https://i.ibb.co/FbLFScR/closing-channel-ss-17.png)

Closing a payment channel can be a necessary step in managing your Lightning Network wallet and ensuring the security and flexibility of your funds.

## Node and Channel Backups
As we continue our journey, it's important to note that we don't currently have a channel backup mechanism in place. All the data related to node and channel states are stored locally in the `storagePath` as defined in the `createOrRecoverWallet` method.

This is actually a very important consideration when running a Lightning node, is the issue of backups. Unlike a Bitcoin wallet, where a BIP-39 mnemonic phrase and BIP-32 can recover the entire state of the wallet. However, in Lightning, things are a bit more complex.

Lightning wallets do use a BIP-39 mnemonic phrase for on-chain wallet backup, but this phrase alone is not sufficient to restore a Lightning node. Channels, which are a fundamental part of the Lightning Network, are constructed in a way that the mnemonic phrase can't fully restore a Lightning node.

And also, when it comes to channel state backups, there's no standardized approach that every Lightning wallet follows. Some wallets store channel states on Google Drive, some on their own remote servers, and others store them locally on the user's device. Each of these practices carries the risk of data loss and data inconsistency risks.

So there is no consistent backup mechanism across different Lightning node and wallet implementations. Hence, you should not store large amounts in a Lightning wallet.  Large amounts should be kept in a cold wallet that is not online and can only transact on-chain.

It's crucial to keep this in mind to ensure the safety and security of your funds when operating on the Lightning Network.

## Incoming Channel Opening Requests Struggle
During the development of this project, I encountered a significant challenge related to incoming channel opening requests. I initially struggled while attempting to build the node in the `createOrRecoverWallet` method, particularly when using the `.setListeningAddress` method on `ldk.Builder()`. To enable incoming channel opening requests, it's essential to set the listening address by specifying the IP address and listening port for the node, allowing it to listen for incoming channel requests.

However, after extensive efforts and seeking guidance in the LDK Discord channel, I learned that running a node configured to listen for incoming connections is not a viable approach for mobile phones.

Setting the IP address to the mobile device's IPv4 public address, which essentially corresponds to the ISP's address, presents challenges. This IP address is not stable, and many mobile providers place end devices behind NAT (Network Address Translation), further complicating the situation.

In the words of @tnull, "if you don't want to go out of your way to implement hole punching or similar, I'd generally recommend disabling the listening port on mobile devices and relying on outbound connections only."

You can find the complete communication on this topic here(https://discord.com/channels/915026692102316113/978829624635195422/1155768160197279744), where @tnull provided a detailed explanation of this issue.

Also, benthecarman suggested that the "best approach is probably just not calling setListeningAddress." This is the approach I followed in the `createOrRecoverWallet` method.

For these reasons, we cannot have incoming channel opening requests on mobile devices. It's crucial to be aware of these limitations and work within the constraints of the mobile environment when developing Lightning Network applications.

## Conclusion
As we wrap up this journey into the fascinating world of the Lightning Network, I want to express my deep thanks to the amazing team working on the LDK node project and all the dedicated developers who have contributed to the development of BDK and LDK. Your hard work not only opens new doors but also supports developers like me who are diving into the potential of this incredible technology.

The Lightning Network isn't just a technological advance; it's a game-changer that promises faster, cheaper, and more efficient Bitcoin transactions. It unlocks countless possibilities, from tiny payments to decentralized finance and beyond.

But remember, this is just the start. The Lightning Network is a vast and exciting world with endless opportunities. I encourage all readers to keep learning and explore further. Embrace this technology, experiment with it, and let your imagination run wild. The Lightning Network is a wave of innovation, and you have the chance to ride it.

If you have questions or want to connect and share your experiences, feel free to reach out to me on [Twitter](https://twitter.com/Anipy1), [Nostr](https://snort.social/p/npub1clqc0wnk2vk42u35jzhc3emd64c0u4g6y3su4x44g26s8waj2pzskyrp9x), or [LinkedIn](https://www.linkedin.com/in/aniketambore/).

Thank you for joining me on this journey. ⚡🌊
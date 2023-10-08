import 'package:bijli_ln_wallet/component_library/component_library.dart';
import 'package:bijli_ln_wallet/domain_models/domain_models.dart';
import 'package:bijli_ln_wallet/wallet_repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'wallet_information_cubit.dart';

class WalletInformationScreen extends StatelessWidget {
  const WalletInformationScreen({
    super.key,
    required this.walletRepository,
  });
  final WalletRepository walletRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalletInformationCubit>(
      create: (_) => WalletInformationCubit(walletRepository: walletRepository),
      child: const _WalletInfoView(),
    );
  }
}

class _WalletInfoView extends StatelessWidget {
  const _WalletInfoView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletInformationCubit, WalletInformationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Wallet Information"),
          ),
          body: Container(
            padding: const EdgeInsets.all(Spacing.mediumLarge),
            child: state is WalletInformationSuccess
                ? _WalletInformationSuccess(
                    mnemonic: state.mnemonic,
                    walletInfo: state.walletInfo,
                  )
                : state is WalletInformationFailure
                    ? ExceptionIndicator(
                        onTryAgain: () {
                          final cubit = context.read<WalletInformationCubit>();
                          cubit.refetch();
                        },
                      )
                    : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class _WalletInformationSuccess extends StatefulWidget {
  const _WalletInformationSuccess({
    required this.walletInfo,
    required this.mnemonic,
  });
  final Wallet walletInfo;
  final List<String> mnemonic;

  @override
  State<_WalletInformationSuccess> createState() =>
      __WalletInformationSuccessState();
}

class __WalletInformationSuccessState extends State<_WalletInformationSuccess> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          "Current Esplora Server",
          widget.walletInfo.esploraUrl,
        ),
        const SizedBox(height: Spacing.mediumLarge),
        _buildInfoRow(
          "Current Network",
          widget.walletInfo.network,
        ),
        const SizedBox(height: Spacing.mediumLarge),
        _buildInfoRow(
          "Backup Phrase",
          "This 12-words phrase is your key to recovering your wallet and funds. Keep it safe and never share it with anyone.",
        ),
        const SizedBox(height: Spacing.medium),
        ElevatedButton(
          onPressed: () {
            _showMnemonicDialog(context);
          },
          child: const Text(
            "Display Mnemonic",
          ),
        ),
        const SizedBox(height: Spacing.mediumLarge),
        _buildInfoRow(
          "Node Id",
          widget.walletInfo.nodeId,
        ),
        const SizedBox(height: Spacing.medium),
        ElevatedButton(
          onPressed: () {
            _showPeerListDialog(context);
          },
          child: const Text("List Channel Peer"),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  void _showMnemonicDialog(BuildContext context) {
    final mnemonic = widget.mnemonic;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Keep these words safe. Do not share"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildColumnItems(0, mnemonic.length ~/ 2),
                  _buildColumnItems(mnemonic.length ~/ 2, mnemonic.length),
                ],
              )
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMnemonicWord(String word) {
    return Text(
      word,
      style: const TextStyle(fontSize: FontSize.medium),
    );
  }

  Widget _buildColumnItems(int startIndex, int endIndex) {
    final mnemonic = widget.mnemonic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(endIndex - startIndex, (index) {
        final wordIndex = index + startIndex + 1;
        final word = mnemonic[index + startIndex];
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMnemonicWord('$wordIndex. '),
            _buildMnemonicWord(word),
          ],
        );
      }),
    );
  }

  void _showPeerListDialog(BuildContext context) {
    final peers = widget.walletInfo.peersList;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Node Peers"),
          content: peers.isEmpty
              ? const Text(
                  'Oops! It seems you don\'t have any connected peers on the Lightning Network.')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final peer in peers)
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                peer.isConnected ? Colors.green : Colors.red,
                            child: const Icon(
                              Icons.connect_without_contact_outlined,
                              color: Colors.white,
                            ),
                          ),
                          title: Text("Node ID: ${peer.nodeId.internal}"),
                          subtitle: Text("Address: ${peer.address.addr}"),
                          trailing: Text("Port: ${peer.address.port}"),
                        ),
                    ],
                  ),
                ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("CLOSE"),
            ),
          ],
        );
      },
    );
  }
}

// class WalletInformationScreen extends StatelessWidget {
//   WalletInformationScreen({super.key});

//   final mnemonic = <String>[
//     'girl',
//     'shell',
//     'library',
//     'stick',
//     'seat',
//     'forest',
//     'speak',
//     'abstract',
//     'panic',
//     'admit',
//     'prize',
//     'element',
//   ];

//   final List<PeerDetails> peers = [
//     const PeerDetails(
//       nodeId: PublicKey(
//           internal:
//               '030c3f19d742ca294a55c00376b3b355c3c90d61c6b6b39554dbc7ac19b141c14f'),
//       address: NetAddress.iPv4(addr: '54.77.250.40', port: 9735),
//       isConnected: true,
//     ),
//     const PeerDetails(
//       nodeId: PublicKey(
//           internal:
//               '030c3f19d742ca294a55c00376b3b355c3c90d61c6b6b39554dbc7ac19b141c14f'),
//       address: NetAddress.iPv4(addr: '54.77.250.40', port: 9735),
//       isConnected: true,
//     ),
//     const PeerDetails(
//       nodeId: PublicKey(
//           internal:
//               '030c3f19d742ca294a55c00376b3b355c3c90d61c6b6b39554dbc7ac19b141c14f'),
//       address: NetAddress.iPv4(addr: '54.77.250.40', port: 9735),
//       isConnected: true,
//     ),
//     const PeerDetails(
//       nodeId: PublicKey(
//           internal:
//               "03c2abfa93eacec04721c019644584424aab2ba4dff3ac9bdab4e9c97007491dda"),
//       address: NetAddress.iPv4(addr: '54.77.250.40', port: 9735),
//       isConnected: false,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Wallet Information"),
      // ),
//       body: Container(
//         padding: const EdgeInsets.all(Spacing.mediumLarge),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
          // children: <Widget>[
          //   _buildInfoRow(
          //     "Current Esplora Server",
          //     "mempool.space/testnet/api",
          //   ),
          //   const SizedBox(height: Spacing.mediumLarge),
          //   _buildInfoRow(
          //     "Current Network",
          //     "Testnet",
          //   ),
          //   const SizedBox(height: Spacing.mediumLarge),
          //   _buildInfoRow(
          //     "Backup Phrase",
          //     "This 12-words phrase is your key to recovering your wallet and funds. Keep it safe and never share it with anyone.",
          //   ),
          //   const SizedBox(height: Spacing.medium),
          //   ElevatedButton(
          //     onPressed: () {
          //       _showMnemonicDialog(context);
          //     },
          //     child: const Text(
          //       "Display Mnemonic",
          //     ),
          //   ),
          //   const SizedBox(height: Spacing.mediumLarge),
          //   _buildInfoRow(
          //     "Node Id",
          //     "03ba00a57cec1cef4873065ad54d0912696274cc53155b29a3b1256720e33a0943",
          //   ),
          //   const SizedBox(height: Spacing.medium),
          //   ElevatedButton(
          //     onPressed: () {
          //       // Implement channel peer list functionality here
          //       _showPeerListDialog(context);
          //     },
          //     child: const Text("List Channel Peer"),
          //   ),
          // ],
//         ),
//       ),
//     );
//   }

  // Widget _buildInfoRow(String label, String value) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       Text(
  //         label,
  //         style: const TextStyle(
  //           fontSize: 18.0,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 8.0),
  //       Text(
  //         value,
  //         style: const TextStyle(
  //           fontSize: 16.0,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // void _showMnemonicDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Keep these words safe. Do not share"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: [
  //                 _buildColumnItems(0, mnemonic.length ~/ 2),
  //                 _buildColumnItems(mnemonic.length ~/ 2, mnemonic.length),
  //               ],
  //             )
  //           ],
  //         ),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text("OK"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildMnemonicWord(String word) {
  //   return Text(
  //     word,
  //     style: const TextStyle(fontSize: FontSize.medium),
  //   );
  // }

  // Widget _buildColumnItems(int startIndex, int endIndex) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: List.generate(endIndex - startIndex, (index) {
  //       final wordIndex = index + startIndex + 1;
  //       final word = mnemonic[index + startIndex];
  //       return Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           _buildMnemonicWord('$wordIndex. '),
  //           _buildMnemonicWord(word),
  //         ],
  //       );
  //     }),
  //   );
  // }

  // void _showPeerListDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Node Peers"),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               for (final peer in peers)
  //                 ListTile(
  //                   leading: CircleAvatar(
  //                     backgroundColor:
  //                         peer.isConnected ? Colors.green : Colors.red,
  //                     child: const Icon(
  //                       Icons.connect_without_contact_outlined,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                   title: Text("Node ID: ${peer.nodeId.internal}"),
  //                   subtitle: Text("Address: ${peer.address.addr}"),
  //                   trailing: Text("Port: ${peer.address.port}"),
  //                 ),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text("CLOSE"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
// }
// }
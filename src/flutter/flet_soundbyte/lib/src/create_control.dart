// import 'package:flet/flet.dart';
//
// import 'flet_soundbyte.dart';
//
// CreateControlFactory createControl = (CreateControlArgs args) {
//   switch (args.control.type) {
//     case "flet_soundbyte":
//       return SoundbyteControl(
//         parent: args.parent,
//         control: args.control,
//       );
//     default:
//       return null;
//   }
// };
//
// void ensureInitialized() {
//   // nothing to initialize
// }
import 'package:flet/flet.dart';
import 'flet_soundbyte.dart';

CreateControlFactory createControl = (CreateControlArgs args) {
  switch (args.control.type) {
    case "flet_soundbyte":
      return SoundbyteControl(
        parent: args.parent,
        control: args.control,
        backend: args.backend,
      );
    default:
      return null;
  }
};

void ensureInitialized() {
  // Optional init logic
}

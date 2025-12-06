import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:http/http.dart' as http;

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  String? uid;
  final TextEditingController nameController = TextEditingController();
  bool saving = false;

  @override
  void initState() {
    super.initState();
    startNfcScan();
  }

  // ============================================================
  // NFC SCAN
  // ============================================================
  void startNfcScan() async {
    bool available = await NfcManager.instance.isAvailable();
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("NFC tidak tersedia di HP ini")),
      );
      return;
    }

    NfcManager.instance.startSession(
      onDiscovered: (tag) async {
        final bytes =
            tag.data["mifareclassic"]?["identifier"] ??
            tag.data["nfca"]?["identifier"] ??
            tag.data["ndef"]?["identifier"];

        if (bytes != null) {
          final String uidStr = bytes
              .map((e) => e.toRadixString(16).padLeft(2, '0'))
              .join(':');

          setState(() => uid = uidStr.toUpperCase());
        }

        NfcManager.instance.stopSession();
      },
    );
  }

  // ============================================================
  // 🔐 DIALOG PASSWORD ADMIN
  // ============================================================
  Future<bool> showAdminPasswordDialog() async {
    TextEditingController passC = TextEditingController();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.blueGrey.shade900,
              title: const Text(
                "Verifikasi Admin",
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                controller: passC,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Masukkan Password Admin",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  child: const Text("Verifikasi"),
                  onPressed: () {
                    if (passC.text == "admin123") {
                      Navigator.pop(context, true);
                    } else {
                      Navigator.pop(context, false);
                    }
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // ============================================================
  // SAVE USER + PASSWORD ADMIN
  // ============================================================
  Future<void> saveUser() async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tempelkan kartu terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nama tidak boleh kosong"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool verified = await showAdminPasswordDialog();
    if (!verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password admin salah!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => saving = true);

    final response = await http.post(
      Uri.parse("http://10.180.109.72:8080/api/add-user"),
      body: {"uid": uid!, "name": nameController.text},
    );

    setState(() => saving = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "User berhasil disimpan",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "UID Sudah Terdaftar",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        title: const Text(
          "Tambah User",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blueGrey.shade800,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.nfc, size: 40, color: Colors.blue.shade300),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Tempelkan kartu NFC ke bagian belakang HP...",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              if (uid != null)
                Card(
                  color: Colors.blueGrey.shade800,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kartu Terdeteksi",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          uid!,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          "Masukkan Nama User:",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Nama User",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.blueGrey.shade700,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade600,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: saving ? null : saveUser,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.blue.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "Simpan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        // ====================================================
                        // ⬅ DITAMBAHKAN: TOMBOL SCAN NFC BARU
                        // ====================================================
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                uid = null; // reset UID
                                nameController
                                    .clear(); // 🔥 reset input username
                              });
                              startNfcScan(); // mulai scan ulang
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Scan Lagi",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // ====================================================
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

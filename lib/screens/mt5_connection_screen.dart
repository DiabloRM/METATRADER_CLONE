import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mt5_provider.dart';
import '../models/mt5_settings_model.dart';

class MT5ConnectionScreen extends StatefulWidget {
  const MT5ConnectionScreen({Key? key}) : super(key: key);

  @override
  State<MT5ConnectionScreen> createState() => _MT5ConnectionScreenState();
}

class _MT5ConnectionScreenState extends State<MT5ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _portController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isConnecting = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // Set default values
    _serverController.text = '149.28.153.205';
    _portController.text = '443';
    _loginController.text = '62333850';
    _passwordController.text = 'tecimil4';
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connectToMT5() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
    });

    try {
      final mt5Provider = Provider.of<MT5Provider>(context, listen: false);

      final result = await mt5Provider.connectToMT5(
        serverIp: _serverController.text.trim(),
        serverPort: int.parse(_portController.text.trim()),
        login: _loginController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result['success'] == true) {
        setState(() {
          _isConnected = true;
        });

        // Save settings
        final settings = MT5Settings(
          server: _serverController.text.trim(),
          port: int.parse(_portController.text.trim()),
          login: _loginController.text.trim(),
          password: _passwordController.text.trim(),
          useEncryption: true,
          defaultDeposit: 1000.0,
        );
        await mt5Provider.saveSettings(settings);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully connected to MT5 server!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _disconnectFromMT5() async {
    try {
      final mt5Provider = Provider.of<MT5Provider>(context, listen: false);
      await mt5Provider.disconnectFromMT5();

      setState(() {
        _isConnected = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disconnected from MT5 server'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error disconnecting: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MT5 Connection'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connection Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.check_circle : Icons.error,
                        color: _isConnected ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isConnected
                              ? 'Connected to MT5 Server'
                              : 'Not Connected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Server Settings
              Text(
                'Server Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Server IP
              TextFormField(
                controller: _serverController,
                decoration: InputDecoration(
                  labelText: 'Server IP',
                  hintText: 'Enter MT5 server IP address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.dns),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter server IP';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Server Port
              TextFormField(
                controller: _portController,
                decoration: InputDecoration(
                  labelText: 'Server Port',
                  hintText: 'Enter MT5 server port',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.router),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter server port';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid port number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 24),

              // Account Settings
              Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Login
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: 'Login',
                  hintText: 'Enter your MT5 account login',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter login';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your MT5 account password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),

              SizedBox(height: 32),

              // Action Buttons
              if (!_isConnected) ...[
                ElevatedButton(
                  onPressed: _isConnecting ? null : _connectToMT5,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isConnecting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Connecting...'),
                          ],
                        )
                      : Text('Connect to MT5'),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _disconnectFromMT5,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Disconnect'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Go to Trading'),
                ),
              ],

              SizedBox(height: 24),

              // Info Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection Info',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Make sure your MT5 server is running and accessible\n'
                        '• Use demo account credentials for testing\n'
                        '• Default port is 443 for HTTPS connections\n'
                        '• Contact your broker for correct server details',
                        style: TextStyle(fontSize: 14),
                      ),
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

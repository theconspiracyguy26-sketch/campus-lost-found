import 'package:flutter/material.dart';
import '../widgets/gradient_scaffold.dart';
import '../services/appwrite_service.dart';
import 'welcome_page.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _college = TextEditingController();
  bool _loading = false;

  _signup() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppwriteService.signUp(name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim(), college: _college.text.trim());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WelcomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientScaffold(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Campus Lost & Found', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      TextFormField(controller: _name, decoration: InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'required' : null),
                      TextFormField(controller: _email, decoration: InputDecoration(labelText: 'Email'), validator: (v) => v!.contains('@') ? null : 'invalid'),
                      TextFormField(controller: _phone, decoration: InputDecoration(labelText: 'Phone'), validator: (v) => v!.isEmpty ? 'required' : null),
                      TextFormField(controller: _college, decoration: InputDecoration(labelText: 'College Name'), validator: (v) => v!.isEmpty ? 'required' : null),
                      SizedBox(height: 12),
                      ElevatedButton(onPressed: _loading ? null : _signup, child: _loading ? CircularProgressIndicator() : Text('Sign up / Login'))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

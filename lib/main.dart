import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import './Home.dart';
import './Register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialise Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnilistV2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Affiche la page de connexion au démarrage
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new HomePage(userEmail: ''), // Page d'accueil
        '/login': (BuildContext context) => new LoginPage(), // Page de connexion
        '/register': (BuildContext context) => new RegisterPage(), // Page d'inscription
      },
    );
  }
}


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email, _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.5,
                child:
                TextFormField(
                  validator: (input) {
                    if (input == null || input == "") {
                      return 'Veuillez entrer un e-mail';
                    }
                    return null;
                  },
                  onSaved: (input) => _email = input!,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                  ),
                ),
              ),
              SizedBox(height: 16.0), // Espacement
              FractionallySizedBox(
                widthFactor: 0.5,
                child:
                TextFormField(
                  validator: (input) {
                    if (input == null || input.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                  onSaved: (input) => _password = input!,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 16.0), // Espacement
              ElevatedButton(
                onPressed: signIn,
                child: Text('Se connecter'),
              ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                  },
                  child: Text('Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signIn() async {
    final formState = _formKey.currentState;
    if (formState!.validate()) {
      formState.save();
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        // L'utilisateur est connecté avec succès
        print(userCredential.user);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userEmail: _email),
          ),
        );
      } catch (e) {
        print(e);
      }
    }
  }
}
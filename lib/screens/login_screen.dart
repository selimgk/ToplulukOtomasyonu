import 'package:flutter/material.dart';
import 'package:derss1/models/user_role.dart';
import 'package:derss1/database_helper.dart';
import 'package:derss1/models.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  late UserRole _targetRole;
  bool _isInit = false;
  
  // Registration State
  bool _isLogin = true;
  List<Community> _communities = [];
  Community? _selectedCommunity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is UserRole) {
        _targetRole = args;
      } else {
        _targetRole = UserRole.student; 
      }
      
      if (_targetRole == UserRole.admin) {
        _fetchCommunities();
      }
      _isInit = true;
    }
  }

  Future<void> _fetchCommunities() async {
    final communities = await DatabaseHelper.instance.readCommunitiesForRegistration();
    setState(() {
      _communities = communities;
    });
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (username.isEmpty || password.isEmpty) {
       setState(() {
        _errorMessage = 'Lütfen tüm alanları doldurunuz.';
      });
      return;
    }

    if (_targetRole == UserRole.admin) {
      if (_isLogin) {
        // --- Admin Login ---
         try {
           final community = await DatabaseHelper.instance.checkAdminLogin(username, password);
           if (community != null) {
              _navigateToHome(username);
           } else {
             setState(() {
               _errorMessage = 'Hatalı kullanıcı adı veya şifre!';
             });
           }
         } catch (e) {
            setState(() {
               _errorMessage = 'Giriş hatası: $e';
             });
         }
      } else {
        // --- Admin Registration ---
        if (_selectedCommunity == null) {
           setState(() {
            _errorMessage = 'Lütfen yönettiğiniz topluluğu seçiniz.';
          });
          return;
        }
        
        try {
          final success = await DatabaseHelper.instance.registerAdmin(
            _selectedCommunity!.id!, 
            username, 
            password
          );
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
            );
            setState(() {
              _isLogin = true; // Switch to login
            });
          } else {
             setState(() {
               _errorMessage = 'Bu kullanıcı adı zaten alınmış.';
             });
          }
        } catch (e) {
           setState(() {
               _errorMessage = 'Kayıt hatası: $e';
             });
        }
      }
    } else {
      // --- Student Login --- (Unchanged logic, kept simpler for brevity in diff but logic preserved)
      final studentNumberRegex = RegExp(r'^\d{9}$');
      
      if (!studentNumberRegex.hasMatch(password)) {
         setState(() {
          _errorMessage = 'Öğrenci numarası 9 haneli bir sayı olmalıdır!';
        });
        return;
      }
      
      // Verification passed
      _navigateToHome(username);
    }
  }

  void _navigateToHome(String username) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/events',
        (route) => false,
        arguments: {
          'role': _targetRole,
          'username': username,
          'studentNumber': _targetRole == UserRole.student ? _passwordController.text.trim() : null,
        },
      );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safety check in case widget builds before dependencies
    if (!_isInit) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final title = _targetRole == UserRole.admin 
        ? (_isLogin ? 'Yönetici Girişi' : 'Yönetici Kayıt') 
        : 'Öğrenci Girişi';
    final icon = _targetRole == UserRole.admin ? Icons.admin_panel_settings : Icons.school;


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)], // Navy Blue Gradient
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                color: Colors.white.withValues(alpha: 0.15), // Frosted Glass effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          icon,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 48),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          fillColor: Colors.transparent, 
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 24),
                      if (_targetRole == UserRole.admin && !_isLogin) ...[
                        const SizedBox(height: 24),
                        DropdownButtonFormField<Community>(
                          value: _selectedCommunity,
                          items: _communities.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                c.name.length > 25 ? '${c.name.substring(0, 25)}...' : c.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCommunity = val;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Yönettiğiniz Topluluk',
                            prefixIcon: Icon(Icons.group_work, color: Colors.white),
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                             fillColor: Colors.transparent,
                          ),
                          dropdownColor: const Color(0xFF283593),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                      const SizedBox(height: 24),
                      TextField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                        labelText: _targetRole == UserRole.student ? 'Öğrenci Numarası' : 'Şifre',
                          hintText: _targetRole == UserRole.student ? '9 haneli öğrenci numarası' : null,
                          prefixIcon: const Icon(Icons.lock, color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          fillColor: Colors.transparent,
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: _targetRole == UserRole.student ? TextInputType.number : TextInputType.text,
                        onSubmitted: (_) => _login(),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                          elevation: 8,
                        ),
                        child: Text(
                          _isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                          style: const TextStyle(fontSize: 18, letterSpacing: 1),
                        ),
                      ),
                      if (_targetRole == UserRole.admin) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _errorMessage = null;
                            });
                          },
                          child: Text(
                            _isLogin ? 'Hesabınız yok mu? Kayıt Olun' : 'Zaten hesabınız var mı? Giriş Yapın',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ]
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

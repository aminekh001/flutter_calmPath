import 'package:calm_path/data/models/auth/create_user_req.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class AuthFirebaseService {


  Future<void>signup(CreateUserReq createUserReq );
  Future<void>signin();


  
}
class AuthFirebaseServiceImp extends AuthFirebaseService{
  @override
  Future<void> signin() {
    // TODO: implement signin
    throw UnimplementedError();
  }

  @override
  Future<void> signup(CreateUserReq createUserReq ) async {
    // TODO: implement signup
    try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: createUserReq.email, 
          password: createUserReq.password);
    }on FirebaseException catch(e){}
  }
  
}
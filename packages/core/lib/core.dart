export 'colors/app_colors.dart';
export 'theme/app_theme.dart';



main(){
A a = A(5,6)..a=10..b=20;
     print(a.a);
     print(a.b);
} 


class A{
  int a =10;
  int b= 20;
  A(this.a, this.b);
}
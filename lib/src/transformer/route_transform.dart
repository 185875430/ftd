import 'package:kernel/ast.dart';
import 'package:front_end/src/fasta/kernel/internal_ast.dart';
import '../tool/store_utils.dart';


class RouteTransform extends RecursiveVisitor<void> {

  @override
  void visitProcedure(Procedure node) {
    super.visitProcedure(node);
    String procedureName = node.name.name;
    if( procedureName.contains('didPush')) {
      if (node.parent is Class) {
        final Class cls = node.parent;
        print("yongyuan.wu RouteTransform visitProcedure cls ${cls}");
        if (cls.name == 'RouteObserver') {
          final FunctionNode functionNode = node.function;
          final Block block = functionNode.body;
          final ArgumentsImpl argumentsImpl  = ArgumentsImpl(<Expression>[StringConcatenation(<Expression>[StringLiteral('return value = 11111')])]);
          final StaticInvocation staticInvocation = StaticInvocation(Stores.printProcedure,argumentsImpl,isConst: false);
          final ExpressionStatement expressionStatement = ExpressionStatement(staticInvocation);
          block.statements.insert(0, expressionStatement);
        }
      }
    }
  }
}
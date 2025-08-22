// import 'package:flutter/material.dart';
// import 'package:source_base/presentation/blocs/switch_final_deal/models/selected_product_item.dart';
// import 'package:source_base/presentation/screens/shared/widgets/product_selection_bottom_sheet.dart';

// /// 示例：如何使用多产品选择功能
// class ProductSelectionExample extends StatelessWidget {
//   const ProductSelectionExample({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('多产品选择示例'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             // 显示产品选择底部弹窗
//             final result =
//                 await showModalBottomSheet<List<SelectedProductItem>>(
//               context: context,
//               isScrollControlled: true,
//               backgroundColor: Colors.transparent,
//               builder: (context) => const ProductSelectionBottomSheet(),
//             );

//             // 处理选择结果
//             if (result != null && result.isNotEmpty) {
//               print('已选择 ${result.length} 个产品:');
//               for (final productItem in result) {
//                 print(
//                     '- ${productItem.product.name}: ${productItem.quantity} x ${productItem.product.price} = ${productItem.totalWithTax}');
//               }
//             }
//           },
//           child: const Text('选择产品'),
//         ),
//       ),
//     );
//   }
// }

// /// 使用说明：
// /// 
// /// 1. 新的多产品选择功能允许用户选择多个产品，每个产品都有独立的数量设置
// /// 
// /// 2. 主要改进：
// ///    - 支持选择多个产品
// ///    - 每个产品项都有独立的数量输入
// ///    - 实时计算每个产品的总价（包含税费）
// ///    - 可以单独删除某个产品
// ///    - 自动计算所有产品的总金额
// /// 
// /// 3. 新的数据模型：
// ///    - SelectedProductItem: 包含产品信息、数量、总价等
// ///    - 支持从ProductModel创建SelectedProductItem
// ///    - 自动计算税费和总价
// /// 
// /// 4. 新的Bloc事件：
// ///    - AddProductToSelection: 添加产品到选择列表
// ///    - UpdateProductQuantity: 更新产品数量
// ///    - RemoveProductFromSelection: 从选择列表中移除产品
// /// 
// /// 5. 状态管理：
// ///    - SwitchFinalDealState现在包含selectedProducts列表
// ///    - 支持多个产品的状态管理
// ///    - 自动更新总金额计算
// /// 
// /// 6. UI组件：
// ///    - ProductSelectionBottomSheet: 主选择界面
// ///    - ProductSelectionItem: 单个产品项组件
// ///    - 支持产品选择、数量输入、删除等功能 
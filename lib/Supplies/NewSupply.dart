import 'dart:math';

import 'package:denario/Backend/DatabaseService.dart';
import 'package:denario/Models/Supplier.dart';
import 'package:denario/Models/Supply.dart';
import 'package:denario/Suppliers/SuppliersListDialog.dart';
import 'package:denario/Supplies/SuppliesListDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NewSupply extends StatefulWidget {
  final String activeBusiness;
  final Supply supply;
  const NewSupply(this.activeBusiness, this.supply, {Key key})
      : super(key: key);

  @override
  State<NewSupply> createState() => _NewSupplyState();
}

class _NewSupplyState extends State<NewSupply> {
  final _formKey = GlobalKey<FormState>();
  final formatCurrency = new NumberFormat.simpleCurrency();

  String name = '';
  String unit = '';
  double price = 0;
  double qty;
  List sellers = [];
  List historicPrices;
  bool newSupply;
  List selectedVendors = [];
  List unitList = [
    'Unidades',
    'Gramos',
    'Kilogramos',
    'Mililitros',
    'Litros',
    'Libras',
    'Onzas',
  ];
  TextEditingController priceController = new TextEditingController();

  //List of ingredients
  List ingredients = [];
  ValueKey redrawObject = ValueKey('List');
  List<TextEditingController> _controllers = [];
  double totalIngredientsCost() {
    double totalCost = 0;
    for (int i = 0; i < ingredients.length; i++) {
      double ingredientTotal =
          ((ingredients[i]['Supply Cost'] / ingredients[i]['Supply Quantity']) *
                  ingredients[i]['Quantity']) /
              ingredients[i]['Yield'];
      if (!ingredientTotal.isNaN &&
          !ingredientTotal.isInfinite &&
          !ingredientTotal.isNegative) {
        totalCost = totalCost + ingredientTotal;
      }
    }
    setState(() {
      priceController.text = totalCost.toStringAsFixed(2);
    });
    return totalCost;
  }

  void selectSupply(
      String supply, String unit, double supplyCost, double supplyQty) {
    for (var x = 0; x < 2; x++) {
      _controllers.add(new TextEditingController());
    }
    setState(() {
      ingredients.add({
        'Ingredient': supply,
        'Quantity': 0,
        'Yield': 0,
        'Unit': unit,
        'Supply Cost': supplyCost,
        'Supply Quantity': supplyQty
      });
    });
  }

  //Lista de letras del nombre
  setSearchParam(String caseNumber) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  bool editedSupply = false;

  void selectVendor(Supplier vendor) {
    setState(() {
      sellers.add(vendor.name);
    });
  }

  @override
  void initState() {
    if (widget.supply != null) {
      newSupply = false;
      name = widget.supply.supply;
      price = widget.supply.price;
      unit = widget.supply.unit;
      qty = widget.supply.qty;
      sellers = widget.supply.suppliers;
      ingredients = widget.supply.recipe;
      historicPrices = widget.supply.priceHistory;
      if (widget.supply.recipe.length > 0) {
        // for (var x = 0; x < widget.supply.recipe.length; x++) {
        //   ingredients.add({
        //     'Ingredient': widget.supply.recipe[x].ingredient,
        //     'Quantity': widget.supply.recipe[x].qty,
        //   });
        // }
        priceController.text = totalIngredientsCost().toString();
      } else {
        ingredients = [];
        priceController.text = '';
      }
    } else {
      newSupply = true;
      unit = 'Gramos';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //Title
          Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back),
                    iconSize: 20.0),
                SizedBox(width: 25),
                Text(
                  'Agregar Insumo',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
                ),
              ],
            ),
          ),
          SizedBox(height: 35),
          //Form
          Container(
            width: 600,
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: <BoxShadow>[
                new BoxShadow(
                  color: Colors.grey[350],
                  offset: new Offset(0, 0),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Name
                  Text(
                    'Nombre del Insumo*',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black45),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      cursorColor: Colors.grey,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Agrega un nombre";
                        } else {
                          return null;
                        }
                      },
                      initialValue: name,
                      decoration: InputDecoration(
                        focusColor: Colors.black,
                        hintStyle:
                            TextStyle(color: Colors.black45, fontSize: 14),
                        errorStyle: TextStyle(
                            color: Colors.redAccent[700], fontSize: 12),
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(12.0),
                          borderSide: new BorderSide(
                            color: Colors.grey[350],
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(12.0),
                          borderSide: new BorderSide(
                            color: Colors.green,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  //Price/Qty/Unit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Price
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Precio de compra*',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black45),
                            ),
                            SizedBox(height: 10),
                            (totalIngredientsCost() <= 0)
                                ? Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      enabled: true,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      cursorColor: Colors.grey,
                                      initialValue:
                                          (price > 0) ? price.toString() : '',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                                        TextInputFormatter.withFunction(
                                          (oldValue, newValue) =>
                                              newValue.copyWith(
                                            text: newValue.text
                                                .replaceAll(',', '.'),
                                          ),
                                        ),
                                      ],
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return "Agrega un precio";
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        prefixIcon: Icon(
                                          Icons.attach_money,
                                          color: Colors.grey,
                                        ),
                                        focusColor: Colors.black,
                                        hintStyle: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 14),
                                        errorStyle: TextStyle(
                                            color: Colors.redAccent[700],
                                            fontSize: 12),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(12.0),
                                          borderSide: new BorderSide(
                                            color: Colors.grey[350],
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(12.0),
                                          borderSide: new BorderSide(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value != '' && value != null) {
                                          setState(() {
                                            price = double.parse(value);
                                          });
                                        } else {
                                          setState(() {
                                            price = 0;
                                          });
                                        }
                                      },
                                    ),
                                  )
                                : Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      enabled: false,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 14),
                                      cursorColor: Colors.grey,
                                      controller: priceController,
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        prefixIcon: Icon(
                                          Icons.attach_money,
                                          color: Colors.grey,
                                        ),
                                        focusColor: Colors.black,
                                        hintStyle: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 14),
                                        errorStyle: TextStyle(
                                            color: Colors.redAccent[700],
                                            fontSize: 12),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(12.0),
                                          borderSide: new BorderSide(
                                            color: Colors.grey[350],
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(12.0),
                                          borderSide: new BorderSide(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      //Qty
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Cantidad*',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black45),
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              child: TextFormField(
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                                cursorColor: Colors.grey,
                                initialValue: qty != null ? qty.toString() : '',
                                decoration: InputDecoration(
                                  hintText: '0',
                                  focusColor: Colors.black,
                                  hintStyle: TextStyle(
                                      color: Colors.black45, fontSize: 14),
                                  errorStyle: TextStyle(
                                      color: Colors.redAccent[700],
                                      fontSize: 12),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(12.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey[350],
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(12.0),
                                    borderSide: new BorderSide(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    qty = double.parse(value);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      //Unit
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Unidad de medida*',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.black45),
                            ),
                            SizedBox(height: 10),
                            Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: DropdownButton(
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  hint: Text(
                                    'Gramos',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Colors.grey[700]),
                                  ),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: Colors.grey[700]),
                                  value: unit,
                                  items: unitList.map((x) {
                                    return new DropdownMenuItem(
                                      value: x,
                                      child: new Text(x),
                                      onTap: () {
                                        setState(() {
                                          unit = x;
                                        });
                                      },
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      unit = newValue;
                                    });
                                  },
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  //Vendor Search Bar
                  Text(
                    'Proveedor',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black45),
                  ),
                  SizedBox(height: 10),
                  (sellers.length == 0)
                      ? SizedBox()
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: sellers.length,
                          itemBuilder: ((context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Vendor
                                  Container(
                                    // height: 40,
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: Colors.greenAccent[400],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12))),
                                    child: Text(
                                      sellers[i],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Spacer(),
                                  //Delete
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          sellers.removeAt(i);
                                        });
                                      },
                                      icon: Icon(Icons.close))
                                ],
                              ),
                            );
                          })),
                  SizedBox(height: (sellers.length == 0) ? 0 : 12),
                  Tooltip(
                    message: 'Asociar proveedor',
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: ((context) => SuppliersListDialog(
                                selectVendor, widget.activeBusiness)));
                      },
                      child: Container(
                        height: 40,
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                            SizedBox(width: 10),
                            Text('Asociar proveedor')
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  //Ingredientes
                  Text(
                    'Insumos asociados (opcional)',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.black45),
                  ),
                  SizedBox(height: 10),
                  (ingredients.length == 0)
                      ? SizedBox()
                      : ListView.builder(
                          key: redrawObject,
                          shrinkWrap: true,
                          itemCount: ingredients.length,
                          itemBuilder: ((context, i) {
                            double ingredientTotal = ((ingredients[i]
                                            ['Supply Cost'] /
                                        ingredients[i]['Supply Quantity']) *
                                    ingredients[i]['Quantity']) /
                                ingredients[i]['Yield'];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //Ingrediente
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        cursorColor: Colors.grey,
                                        validator: (val) {
                                          if (val == null || val.isEmpty) {
                                            return "Agrega un ingrediente v??lido";
                                          } else {
                                            return null;
                                          }
                                        },
                                        initialValue: ingredients[i]
                                            ['Ingredient'],
                                        decoration: InputDecoration(
                                          hintText: 'Insumo',
                                          focusColor: Colors.black,
                                          hintStyle: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 12),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 12),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.grey[350],
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            ingredients[i]['Ingredient'] =
                                                value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  //Amount
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        textAlign: TextAlign.center,
                                        initialValue: ingredients[i]
                                                    ['Quantity'] ==
                                                0
                                            ? ''
                                            : '${ingredients[i]['Quantity']}',
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                                          TextInputFormatter.withFunction(
                                            (oldValue, newValue) =>
                                                newValue.copyWith(
                                              text: newValue.text
                                                  .replaceAll(',', '.'),
                                            ),
                                          ),
                                        ],
                                        cursorColor: Colors.grey,
                                        decoration: InputDecoration(
                                          focusColor: Colors.black,
                                          floatingLabelStyle:
                                              TextStyle(color: Colors.grey),
                                          labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                          labelText:
                                              (ingredients[i]['Unit'] != null)
                                                  ? ingredients[i]['Unit']
                                                  : 'Cantidad',
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 12),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.grey[350],
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            ingredients[i]['Quantity'] =
                                                double.parse(value);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  //Yield
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14),
                                        textAlign: TextAlign.center,
                                        initialValue:
                                            ingredients[i]['Yield'] == 0
                                                ? ''
                                                : '${ingredients[i]['Yield']}',
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                                          TextInputFormatter.withFunction(
                                            (oldValue, newValue) =>
                                                newValue.copyWith(
                                              text: newValue.text
                                                  .replaceAll(',', '.'),
                                            ),
                                          ),
                                        ],
                                        cursorColor: Colors.grey,
                                        decoration: InputDecoration(
                                          focusColor: Colors.black,
                                          labelText: 'Rinde para',
                                          floatingLabelStyle:
                                              TextStyle(color: Colors.grey),
                                          labelStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12),
                                          errorStyle: TextStyle(
                                              color: Colors.redAccent[700],
                                              fontSize: 12),
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.grey[350],
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            borderSide: new BorderSide(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            ingredients[i]['Yield'] =
                                                double.parse(value);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  //Cost
                                  Expanded(
                                      flex: 3,
                                      child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                new BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: Colors.grey[350],
                                            ),
                                          ),
                                          padding: EdgeInsets.all(15),
                                          child: Center(
                                            child: Text(
                                              (ingredientTotal.isNaN ||
                                                      ingredientTotal
                                                          .isInfinite ||
                                                      ingredientTotal
                                                          .isNegative)
                                                  ? '0'
                                                  : '\$${ingredientTotal.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ))),

                                  //Delete
                                  IconButton(
                                      onPressed: () {
                                        ingredients.removeAt(i);

                                        final random = Random();
                                        const availableChars =
                                            'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                        final randomString = List.generate(
                                                10,
                                                (index) => availableChars[
                                                    random.nextInt(
                                                        availableChars.length)])
                                            .join();
                                        setState(() {
                                          redrawObject = ValueKey(randomString);
                                        });
                                      },
                                      icon: Icon(Icons.delete))
                                ],
                              ),
                            );
                          })),
                  SizedBox(height: (ingredients.length == 0) ? 0 : 10),
                  (ingredients.length == 0)
                      ? SizedBox()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Costo total del producto: '),
                            Text(
                              formatCurrency.format(totalIngredientsCost()),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              width: 50,
                            )
                          ],
                        ),
                  SizedBox(height: (ingredients.length == 0) ? 0 : 20),
                  //Agregar ingrediente
                  Tooltip(
                    message: 'Agregar insumo',
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: ((context) => SuppliesListDialog(
                                selectSupply, widget.activeBusiness)));
                        // for (var x = 0; x < 2; x++) {
                        //   _controllers.add(new TextEditingController());
                        // }
                        // setState(() {
                        //   ingredients.add(
                        //       {'Ingredient': '', 'Quantity': '', 'Yield': ''});
                        // });
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        child: Center(
                            child: Icon(
                          Icons.add,
                          color: Colors.black87,
                          size: 30,
                        )),
                      ),
                    ),
                  ),
                  //Button
                  SizedBox(height: 35),
                  (newSupply)
                      ? ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.hovered))
                                  return Colors.grey;
                                if (states.contains(MaterialState.focused) ||
                                    states.contains(MaterialState.pressed))
                                  return Colors.grey.shade300;
                                return null; // Defer to the widget's default.
                              },
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              //Add all characters to the list
                              for (int x = 0; x < sellers.length; x++) {
                                String temp = "";
                                for (int i = 0; i < sellers[x].length; i++) {
                                  temp = temp + sellers[x][i];
                                  selectedVendors.add(temp.toLowerCase());
                                }
                              }
                              DatabaseService().createSuppy(
                                  widget.activeBusiness,
                                  name,
                                  setSearchParam(name.toLowerCase()),
                                  (totalIngredientsCost() > 0)
                                      ? totalIngredientsCost()
                                      : price,
                                  unit,
                                  qty,
                                  sellers,
                                  selectedVendors,
                                  ingredients,
                                  [
                                    {
                                      'From Date': DateTime.now(),
                                      'To Date': null,
                                      'Price': price
                                    }
                                  ]);

                              Navigator.of(context).pop();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Center(
                              child: Text('Crear'),
                            ),
                          ))
                      : Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              //Save
                              Expanded(
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.black),
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.hovered))
                                            return Colors.grey;
                                          if (states.contains(
                                                  MaterialState.focused) ||
                                              states.contains(
                                                  MaterialState.pressed))
                                            return Colors.grey.shade300;
                                          return null; // Defer to the widget's default.
                                        },
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        if (widget.supply.price != price) {
                                          historicPrices.last['To Date'] =
                                              DateTime.now();

                                          historicPrices.add({
                                            'From Date': DateTime.now(),
                                            'To Date': null,
                                            'Price': price
                                          });
                                        }
                                        //Add all characters to the list
                                        for (int x = 0;
                                            x < sellers.length;
                                            x++) {
                                          String temp = "";
                                          for (int i = 0;
                                              i < sellers[x].length;
                                              i++) {
                                            temp = temp + sellers[x][i];
                                            selectedVendors
                                                .add(temp.toLowerCase());
                                          }
                                        }
                                        DatabaseService().editSuppy(
                                            widget.activeBusiness,
                                            widget.supply.docID,
                                            name,
                                            setSearchParam(name.toLowerCase()),
                                            (totalIngredientsCost() > 0)
                                                ? totalIngredientsCost()
                                                : price,
                                            unit,
                                            qty,
                                            sellers,
                                            selectedVendors,
                                            ingredients,
                                            historicPrices);
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                      child: Center(
                                        child: Text('Guardar cambios'),
                                      ),
                                    )),
                              ),
                              SizedBox(width: 20),
                              //Delete
                              Container(
                                height: 45,
                                width: 45,
                                child: Tooltip(
                                  message: 'Eliminar producto',
                                  child: OutlinedButton(
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                          EdgeInsets.all(5)),
                                      alignment: Alignment.center,
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white70),
                                      overlayColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.hovered))
                                            return Colors.grey.shade300;
                                          if (states.contains(
                                                  MaterialState.focused) ||
                                              states.contains(
                                                  MaterialState.pressed))
                                            return Colors.white;
                                          return null; // Defer to the widget's default.
                                        },
                                      ),
                                    ),
                                    onPressed: () {
                                      // DatabaseService().deleteProduct(
                                      //     widget.activeBusiness,
                                      //     widget.supply.docID);
                                      Navigator.of(context).pop();
                                    },
                                    child: Center(
                                        child: Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                      size: 18,
                                    )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}

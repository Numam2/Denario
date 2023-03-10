import 'package:denario/Models/Products.dart';
import 'package:denario/Products/NewProduct.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductList extends StatelessWidget {
  final String businessID;
  final List categories;
  final String businessField;
  final loadMore;
  final int limitSearch;
  ProductList(this.businessID, this.categories, this.businessField,
      this.loadMore, this.limitSearch);

  final formatCurrency = new NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<List<Products>>(context);

    if (products == null) {
      return Container(
        child: Text('Error'),
      );
    }

    if (products.length == 0) {
      return Container(
        width: double.infinity,
        child: Center(child: Text('No se encontraron productos')),
      );
    }

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: ListView.builder(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          itemCount: products.length + 1,
          itemBuilder: (context, i) {
            if (i < products.length) {
              double totalCost = 0;
              List ingredients = products[i].ingredients;
              if (ingredients.length > 0) {
                for (int x = 0; x < ingredients.length; x++) {
                  if (ingredients[x]['Supply Cost'] != null &&
                      ingredients[x]['Supply Quantity'] != null &&
                      ingredients[x]['Quantity'] != null &&
                      ingredients[x]['Yield'] != null) {
                    double ingredientTotal = ((ingredients[x]['Supply Cost'] /
                                ingredients[x]['Supply Quantity']) *
                            ingredients[x]['Quantity']) /
                        ingredients[x]['Yield'];
                    if (!ingredientTotal.isNaN &&
                        !ingredientTotal.isInfinite &&
                        !ingredientTotal.isNegative &&
                        ingredientTotal != null) {
                      totalCost = totalCost + ingredientTotal;
                    }
                  }
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewProduct(businessID,
                                categories, businessField, products[i])));
                  },
                  child: Container(
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Imagen
                        (products[i].image != '')
                            ? Container(
                                height: 75,
                                width: 75,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    color: Colors.grey.shade300,
                                    image: DecorationImage(
                                        image: NetworkImage(products[i].image),
                                        fit: BoxFit.cover)))
                            : Container(
                                height: 75,
                                width: 75,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    color: Colors.grey.shade300)),
                        //Nombre
                        Container(
                            width: 150,
                            child: Text(
                              products[i].product,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )),
                        //C??digo
                        Container(
                            width: 100,
                            child: Text(
                              products[i].code,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black54),
                            )),

                        //Categoria
                        Container(
                            width: 150,
                            child: Text(
                              products[i].category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                            )),

                        //Precio
                        Container(
                            width: 150,
                            child: Text(
                              '${formatCurrency.format(products[i].price)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                        //Precio
                        Container(
                            width: 150,
                            child: Text(
                              '${formatCurrency.format(totalCost)}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.redAccent[700]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                        //Margin
                        Container(
                            width: 100,
                            child: Text(
                              '${(((products[i].price - totalCost) / products[i].price) * 100).toStringAsFixed(0)}%',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ((((products[i].price - totalCost) /
                                                  products[i].price) *
                                              100) >
                                          products[i].lowMarginAlert)
                                      ? Colors.black54
                                      : Colors.redAccent[700]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                        //More Button
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black, size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewProduct(
                                        businessID,
                                        categories,
                                        businessField,
                                        products[i])));
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else if (products.length < limitSearch) {
              return SizedBox();
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Button load more
                    Container(
                      height: 30,
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            loadMore();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            child: Text(
                              'Ver m??s',
                              style: TextStyle(color: Colors.black),
                            ),
                          )),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}

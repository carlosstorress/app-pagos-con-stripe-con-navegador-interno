import 'package:app_pagos_con_webview_con_navegador_interno/stripe_service.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stripe Checkout",
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'img/colegiatura.jpg',
              // Ruta de la imagen
              // Ancho deseado de la imagen
            ),
            const Text(
              'Colegiatura',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '\$4167.60',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            TextButton(
              onPressed: () async {
                var items = [
                  // {
                  //   "productPrice": 4,
                  //   "prudctName": "Apple",
                  //   "qty": 5,
                  // },
                  {
                    "productPrice": 5167.60,
                    "productName": "Colegiatura",
                    "descriptionName": "Pago de colegiatura del mes de agosto",
                    "imageProduct": [
                      "https://pbs.twimg.com/media/EN4I3RhUwAIYGrB?format=png&name=medium"
                    ],
                    "metadata": {
                      "nombrePersonalizado": "Colegiatura Mensual",
                      "etiqueta": "Educación",
                      "instruccionesDePago":
                          "Realizar el pago antes del 5 de agosto",
                      "referenciaInterna": "COLE-202308",
                      "descuento": false,
                    },
                    "qty": 1,
                  },
                ];
                await StripeService.stripePaymentCheckout(
                  items,
                  500,
                  context,
                  mounted,
                  onSuccess: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Pago realizado con exito :)')));
                    print("Pago realizado!");
                  },
                  onCancel: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Pago realizado cancelado')));
                    print("Pago cancelado");
                  },
                  onError: (e) {
                    print("Error al realizar el pago" + e.toString());
                  },
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: const BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1)),
                ),
                minimumSize: Size(150, 50), // Ajusta el tamaño mínimo aquí
              ),
              child: const Text("Pagar"),
            ),
          ],
        ),
      ),
    );
  }
}

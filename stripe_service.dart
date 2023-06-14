import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_checkout/stripe_checkout.dart';

class StripeService {
  static String secretKey =
      "sk_test_51MgqzbFsLXR5H817qiFBGL4OixLEEiAWKPPtuOAPUCzTdGM7ZowHxz4WPOgPbr2gJ5v6thOSJxJ25BwYimGHGNvz00nGyNOPTx";
  static String publishableKey =
      "pk_test_51MgqzbFsLXR5H817ERftCB8k0o5EQwZ2O1kZIVGMowZ8IHwynOLZBu36kl6uD0DBglSypRzQYecgSqWfvs0TuTRh000YGNf2Id";
  // static const colegiaturaId = 'price_1NAchjFsLXR5H817jGVmD55I';

  static Future<dynamic> createCheckoutSession(
    List<dynamic> productItems,
    totalAmount,
  ) async {
    final url = Uri.parse("https://api.stripe.com/v1/checkout/sessions");

    String lineItems = "";
    int index = 0;

    productItems.forEach((val) {
      var productPrice = (val["productPrice"] * 100).round().toString();
      lineItems +=
          "&line_items[$index][price_data][product_data][name]=${val['productName']}";
      lineItems += "&line_items[$index][price_data][unit_amount]=$productPrice";
      lineItems += "&line_items[$index][price_data][currency]=MXN";
      lineItems += "&line_items[$index][quantity]=${val['qty'].toString()}";
      lineItems +=
          "&line_items[$index][price_data][product_data][description]=${val['descriptionName']}";
      // Agregar el campo "metadata" al final del string lineItems
      lineItems +=
          "&line_items[$index][price_data][product_data][metadata][nombre_personalizado]=${val['metadata']['nombrePersonalizado']}";
      lineItems +=
          "&line_items[$index][price_data][product_data][metadata][etiqueta]=${val['metadata']['etiqueta']}";
      // Agregar otros campos de metadata según tus necesidades

      index++;
    });

    final response = await http.post(
      url,
      body:
          'success_url=https://checkout.stripe.dev/success&mode=payment$lineItems&billing_address_collection=required',
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
    );

    return json.decode(response.body)["id"];
  }

  static Future<dynamic> stripePaymentCheckout(
    producItems,
    subTotal,
    context,
    mounted, {
    onSuccess,
    onCancel,
    onError,
  }) async {
    final String sessionId = await createCheckoutSession(
      producItems,
      subTotal,
    );

    final result = await redirectToCheckout(
      context: context,
      sessionId: sessionId,
      publishableKey: publishableKey,
      successUrl: "https://checkout.stripe.dev/success",
      canceledUrl: "https://checkout.stripe.dev/cancel",
    );

    if (mounted) {
      final text = result.when(
        redirected: () => 'Redirected Successfully',
        success: () => onSuccess(),
        canceled: () => onCancel(),
        error: (e) => onError(e),
      );
      return text;
    }
  }
}

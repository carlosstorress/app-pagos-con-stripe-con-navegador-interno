const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

//   // Stripe init
//   const stripe = require("stripe")(functions.config().stripe.secret_key);
//   const session = await stripe.checkout.sessions.create({
//     payment_method_types: ["card"],
//     metadata: {
//       nombrePersonalizado: "Colegiatura Mensual",
//       etiqueta: "Educación",
//       instruccionesDePago:
//           "Realizar el pago antes del 5 de agosto",
//       referenciaInterna: "COLE-202308",
//       descuento: false,
//     },
//     mode: "payment",
//     success_url: "https://carlosstorress.github.io/Pago-con-stripe/",
//     cancel_url: "https://example.com",
//     // shipping_address_collection: {
//     //   allowed_countries: ["MX"],
//     // },
//     billing_address_collection: "required",

//     custom_fields: [
//       {
//         key: "engraving",
//         label: {
//           type: "custom",
//           custom: "Nombre del responsable del pago",
//         },
//         type: "text",
//         text: {
//           maximum_length: 50,
//           minimum_length: 10,
//         },
//       },
//     ],
//     line_items: [
//       {
//         quantity: 1,
//         price_data: {
//           currency: "mxn",
//           unit_amount: (416760) *100, // 10000 = 100 USD
//           product_data: {
//             name: "Colegiatura",
//             images: ["https://pbs.twimg.com/media/EN4I3RhUwAIYGrB?format=png&name=medium"],
//           },
//         },
//       },
//     ],
//   });

//   return {
//     id: session.id,
//   };
// });

exports.createStripeCheckout = functions.https.onCall(async (data, context) => {
  // Stripe init
  const stripe = require("stripe")(functions.config().stripe.secret_key);
  const session = await stripe.checkout.sessions.create({
    payment_method_types: ["card"],
    line_items: data.productItems.map((item) => ({
      price_data: {
        currency: "mxn",
        product_data: {
          name: item.productName,
        },
        unit_amount: item.productPrice * 100,
      },
      quantity: item.qty,
    })),
    mode: "payment",
    success_url: "https://example.com/success",
    cancel_url: "https://example.com/cancel",
  });

  return {
    id: session.id,
  };
});


exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const stripe = require("stripe")(functions.config().stripe.token);
  let event;

  try {
    const whSec = functions.config().stripe.payments_webhook_secret;

    event = stripe.webhooks.constructEvent(
        req.rawBody,
        req.headers["stripe-signature"],
        whSec,
    );
  } catch (err) {
    console.error("⚠️ Webhook signature verification failed.");
    return res.sendStatus(400);
  }

  const dataObject = event.data.object;
  const fechaActual = new Date();

  await admin.firestore().collection("pagos").doc().set({
    checkoutSessionId: dataObject.id,
    paymentStatus: dataObject.payment_status,
    amountTotal: dataObject.amount_total,
    shippingOptions: dataObject.shipping_options,
    customerEmail: dataObject.customer_email,
    customerDetails: dataObject.customer_details,
    totalDetails: dataObject.total_details,
    customFields: dataObject.custom_fields,
    dateTime: fechaActual,
    successUrl: dataObject.success_url,
    cancelUrl: dataObject.cancel_url,
  });
  return res.sendStatus(200);
});
//   await admin.firestore().collection("line_items").doc().set({
//     line_items: [
//       {
//         quantity: 1,
//         price_data: {
//           currency: "mxn",
//           unit_amount: 416760,
//           product_data: {
//             name: "Colegiatura",
//           },
//         },
//       },
//     ],
//   });
//   return res.sendStatus(200);
// });

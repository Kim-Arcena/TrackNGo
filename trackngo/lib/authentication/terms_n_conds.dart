import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:trackngo/authentication/signup_screen.dart';

import '../global/global.dart';

class TermsNConditions extends StatefulWidget {
  @override
  _TermNConState createState() => _TermNConState();
}

class _TermNConState extends State<TermsNConditions> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage("images/background.png"),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView(
            padding: EdgeInsets.all(45.0),
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(
                "Terms and Condition",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              Image.asset('images/banner.png', width: 200.0, height: 200.0),
              AutoSizeText(
                'By downloading, installing, or using TrackNGo, you agree to be bound by these terms and conditions. These Terms constitute a legal agreement between you and TrackNGo Inc., the provider of the App. If you do not agree to these Terms, you must not download, install, or use the App. \n'
                '\nThe App is a platform that connects commuters with privately operating bus drivers in the Pandan Area. The App allows commuters to book seats on buses, pay fares, and track bus locations. The App also allows bus drivers to accept bookings, receive payments, and manage their routes. \n'
                '\nThe Company is not a transportation provider, nor does it own, operate, or control any buses or drivers. The Company is not responsible for the availability, quality, safety, or legality of any buses or drivers. The Company does not guarantee that the App will be error-free, uninterrupted, or secure. \n '
                '\nYou must be at least 18 years old to use the App. You must register an account with the App and provide accurate and complete information about yourself. You must keep your account information confidential and not share it with anyone else. You are responsible for all activities that occur under your account. \n'
                '\nYou must comply with all applicable laws and regulations when using the App. You must not use the App for any unlawful, fraudulent, or malicious purposes. You must not interfere with the operation of the App or damage its functionality. You must not copy, modify, distribute, or reverse engineer any part of the App or its content. \n '
                '\nYou grant the Company a non-exclusive, royalty-free, worldwide license to use, reproduce, modify, and display any content that you submit or post through the App, such as ratings, reviews, feedback, or comments. You represent and warrant that you have the right and authority to grant such license and that your content does not infringe any third-party rights or violate any laws. \n '
                '\nYou acknowledge and agree that your use of the App is at your own risk. The App is provided "as is" and "as available" without any warranties of any kind, either express or implied. The Company disclaims all warranties, including but not limited to warranties of merchantability, fitness for a particular purpose, title, and non-infringement. \n '
                "\nYou agree to indemnify, defend, and hold harmless the Company and its affiliates, directors, officers, employees, agents, partners, and licensors from and against any claims, damages, liabilities, costs, and expenses (including reasonable attorneys' fees) arising out of or related to your use of the App or your breach of these Terms. \n "
                '\nYou agree that any dispute arising out of or related to these Terms or your use of the App shall be governed by the laws of the Philippines without regard to its conflict of laws principles. You agree to submit to the exclusive jurisdiction of the courts located in San Jose for any legal action arising out of or related to these Terms or your use of the App. \n '
                '\nThe Company reserves the right to modify these Terms at any time by posting an updated version on the App. Your continued use of the App after such modification constitutes your acceptance of the modified Terms. \n '
                '\nIf any provision of these Terms is held to be invalid or unenforceable by a court of competent jurisdiction, such provision shall be severed and the remaining provisions shall remain in full force and effect. \n '
                '\nThese Terms constitute the entire agreement between you and the Company regarding your use of the App and supersede any prior or contemporaneous agreements or understandings between you and the Company on this subject matter. \n '
                '\nIf you have any questions or concerns about these Terms or your use of the App, please contact us at support@trackngo.com.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 100,
                textAlign: TextAlign.justify,
              ),
              const SizedBox(
                height: 20,
              ),
              Checkbox(
                value: isChecked,
                checkColor: Colors.white, // color of tick Mark
                activeColor: Color(0xff4e8c6f),
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  });
                },
              ),
              AutoSizeText(
                'I agree with the Terms and Conditions',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                maxLines: 1,
                minFontSize: 10,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

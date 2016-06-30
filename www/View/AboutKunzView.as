import mx.transitions.*;
import mx.transitions.easing.*;

class AboutKunzView extends MvcView
{
   //private var m_cXmlParser:AboutKunzDataXmlParser;
   //private var m_cGlow:GlowHighlight;
   //private var m_cLoadAnimation:LoadAnimation;
   //private var m_cScroller:MovieClipScroller;
   private var m_mcForm:MovieClip;
   private var m_nIndex:Number; //MovieClip Depth Index
   private var m_sName:String;
   private var m_sEmail:String;
   private var m_sMessage:String;
   //private var m_aoAboutKunzData:Object;

   //static private var ABOUT_US_DATA_XML_PATH:String = "Library/Xml/AboutUsData.xml";

   public function AboutKunzView(oController:MvcController, mcViewHolder:MovieClip, cProps:ViewProps)
   {
      super(oController, mcViewHolder, cProps);
      trace("AboutKunzView::AboutKunzView(" + oController + "," +  mcViewHolder + ")");
	  m_nIndex = 0;
	  CreateViewContainer(cProps.sViewName);
   }

   public function EntryViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("AboutKunzView::EntryViewAnimStart");
      super.EntryViewAnimStart(pfDoneEvent);
      createEmailForm();
   }

   private function createEmailForm():Void
   {
      m_mcForm = m_mcView.attachMovie("EmailForm_MC", "EmailForm_MC", m_nIndex++);
      m_mcForm._x = 270;
      m_mcForm._y = 135;
      m_mcForm["BtnSend_MC"].onPress = Fxn.FunctionProxy(this, sendEmail);
      //var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, errorNoPhpSupport), 2000);
	  //cT.StartTimer();
   }
   /*
   private function errorNoPhpSupport():Void
   {
      m_mcForm.gotoAndStop(3);
   }*/

   private function sendEmail():Void
   {
      var txtErr:TextField = m_mcForm["Error_TXT"];
      var mcForm:MovieClip = m_mcForm["Form_MC"];
      var sName:String = mcForm["Name_TXT"].text;
      var sMsg:String = mcForm["Body_TXT"].text;
      var sFromEmail:String = mcForm["Email_TXT"].text;
      var nDotIndex:Number = sFromEmail.lastIndexOf(".");
      var nAtIndex:Number = sFromEmail.indexOf("@");
	  var nEmLen:Number = sFromEmail.length;
      var nSpaceIndex:Number = sFromEmail.indexOf(" ");
      m_sName = sName;
      m_sEmail = sFromEmail;
      m_sMessage = sMsg;
      if(sName.length == 0) txtErr.text = "Error: No Name";
      else if(nEmLen == 0) txtErr.text = "Error: No Email Address";
      else if(nSpaceIndex > -1 || nAtIndex == -1 || nAtIndex > nDotIndex || nAtIndex == nDotIndex - 1 || nDotIndex == nEmLen - 1) txtErr.text = "Error: Invalid Email Address";
      else if(sMsg.length == 0) txtErr.text = "Error: No Message";
      else
      {
         var sToEmail:String = "harrykunz@hkunz.com";
         var sSubject:String = "SkinZone Feedback";
         //var sCC:String = "har_rki219_mc2e@yahoo.com";
         var sGetUrl:String = "mailto:" + sToEmail;
         sGetUrl += "?subject=" + sSubject;
         //sGetUrl += "&cc=" + sCC;
         sGetUrl += "&body=" + sMsg;
         sGetUrl += ("\n\nFrom: " + sName + "\n" + sFromEmail);
         //m_mcForm["Error_TXT"].text =
         //send variables in form movieclip (the textfields)
         //to email PHP page which will send the mail
         //mcForm.loadVariables("HandleEmail.php", "POST");
         getURL(sGetUrl);
         m_mcForm.nextFrame();
         //var cT:EventTimer = new EventTimer(Fxn.FunctionProxy(this, initBackBtn), 500);
         //cT.StartTimer();
         m_mcForm["BtnBack_MC"].onPress = Fxn.FunctionProxy(this, returnToInput);
	  }
   }
   /*
   private function initBackBtn():Void
   {
      var mcForm:MovieClip = m_mcForm["Form_MC"];
      mcForm["BtnBack_MC"].onPress = Fxn.FunctionProxy(this, returnToInput);
   }*/

   private function returnToInput():Void
   {
      m_mcForm.prevFrame();
      var mcForm:MovieClip = m_mcForm["Form_MC"];
      mcForm["Name_TXT"].text = m_sName;
      mcForm["Body_TXT"].text = m_sMessage;
      mcForm["Email_TXT"].text = m_sEmail;
      m_mcForm["BtnSend_MC"].onPress = Fxn.FunctionProxy(this, sendEmail);
   }

   public function ExitViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("AboutKunzView::ExitViewAnimStart");
      super.ExitViewAnimStart(pfDoneEvent);
      animExitComplete();
   }

   private function animExitComplete():Void
   {
      super.ExitViewAnimComplete();
   }

   public function destroy(Void):Void
   {
      trace("AboutKunzView::destroy");
      delete m_sName;
      delete m_sMessage;
      delete m_sEmail;
      //m_cXmlParser.destroy();
	  //delete m_cXmlParser;
      super.destroy();
   }
}
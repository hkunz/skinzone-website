class MvcController
{
   private var m_oModel:MvcModel;
   var m_cPrevView:MvcView;
   var m_cCurView:MvcView;
   var m_mcSysContainer:MovieClip;
   var m_mcViewHolder:MovieClip;

   public function MvcController(oModel:MvcModel)
   {
      trace("MvcController::MvcController(" + oModel + ")");
      m_oModel = oModel;
   }

   public function DrawView(nViewId:Number):Void
   {
      //trace("MvcController::DrawView(" + nViewId + ")");
      switch(nViewId)
	  {
         default:
            break;
	  }
   }

   public function GetCurView(Void):MvcView {return m_cCurView;}
   public function GetPrevView(Void):MvcView {return m_cPrevView;}

   public function destroy(Void):Void
   {
      trace("MvcController::destroy");
	  m_oModel.destroy();
	  m_cPrevView.destroy();
	  m_cCurView.destroy();
	  delete m_cPrevView;
	  delete m_cCurView;
	  delete m_oModel;
	  m_mcSysContainer = null;
	  m_mcViewHolder = null;
   }
}
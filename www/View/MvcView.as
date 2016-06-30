//import mx.transitions.*;
//import mx.transitions.easing.*;

class MvcView
{
   private var m_oController:MvcController;
   private var m_mcViewHolder:MovieClip
   private var m_mcView:MovieClip;
   private var m_pfEntryAnimCompleteEvent:Function;
   private var m_pfExitAnimCompleteEvent:Function;
   private var m_nViewId:Number;
   private var m_nViewState:Number;
   static private var m_nDepth:Number = 50000;

   public function MvcView(oController:MvcController, mcViewHolder:MovieClip, cProps:ViewProps)
   {
      trace("MvcView::MvcView(" + oController + "," + mcViewHolder + ")");
      m_oController = oController;
      m_mcViewHolder = mcViewHolder;
      m_nViewId = cProps.nViewId;
      SetViewState(Enum.VIEW_STATE_INITIALIZE);
   }

   public function GetViewId(Void):Number {return m_nViewId;}
   public function GetViewClip(Void):MovieClip {return m_mcView;}
   public function SetViewState(nViewState:Number):Void {m_nViewState = nViewState;}
   public function GetViewState(Void):Number {return m_nViewState;}

   public function EntryViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("MvcView::EntryViewAnimStart");
      m_pfEntryAnimCompleteEvent = pfDoneEvent;
      SetViewState(Enum.VIEW_STATE_ENTRY_ANIMATION_START);
   }

   public function ExitViewAnimStart(pfDoneEvent:Function):Void
   {
      //trace("MvcView::ExitViewAnimStart");
      m_pfExitAnimCompleteEvent = pfDoneEvent;
	  SetViewState(Enum.VIEW_STATE_EXIT_ANIMATION_START);
   }

   public function EntryViewAnimComplete(Void):Void
   {
      //trace("MvcView::EntryViewAnimComplete");
      SetViewState(Enum.VIEW_STATE_ENTRY_ANIMATION_COMPLETE);
      m_pfEntryAnimCompleteEvent.apply(this);
      delete m_pfEntryAnimCompleteEvent;
   }

   public function ExitViewAnimComplete(Void):Void
   {
      //trace("MvcView::ExitViewAnimComplete");
      SetViewState(Enum.VIEW_STATE_EXIT_ANIMATION_COMPLETE);
      m_pfExitAnimCompleteEvent.apply(this);
      delete m_pfExitAnimCompleteEvent;
   }

   public function CreateViewContainer(sView:String):MovieClip
   {
      //trace("MvcView::CreateViewContainer");
      m_nDepth--;
	  if(m_nDepth < 10) m_nDepth = 50000;
      var nDepth:Number = m_nDepth; //m_mcViewHolder.getNextHighestDepth();
      m_mcView = m_mcViewHolder.createEmptyMovieClip(sView + nDepth, nDepth);
	  m_mcView._x = 0;
	  m_mcView._y = 0;
	  return m_mcView;
   }

   public function SetViewVisible(fVisible:Boolean) {m_mcView._visible = fVisible;}

   public function setViewEnabled(fEnabled):Void
   {

   }

   public function getController():Object
   {
      return m_oController;
   }

   public function destroy(Void):Void
   {
      trace("MvcView::destroy");
	  delete m_oController;
	  delete m_pfEntryAnimCompleteEvent;
      delete m_pfExitAnimCompleteEvent;
	  m_mcView.removeMovieClip();
	  m_mcViewHolder = null;
	  m_mcView = null;
   }
}
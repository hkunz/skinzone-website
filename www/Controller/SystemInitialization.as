class SystemInitialization
{
   var m_oModel:MvcModel;
   var m_oSysController:SystemController;
   var m_mcSysContainer:MovieClip;
   var m_mcSysFont:MovieClip;
   var m_mcGraphics:MovieClip;
   var m_cLoader:MovieClipLoader;
   var m_oListener:Object;
   //var m_oStateInput:Object;

   public function SystemInitialization(Void)
   {
      trace("SystemInitialization::SystemInitialization");
	  //Usage of Fxn.CreateRootMovieClip now creates clips into SzRoot_MC which is the locked _root
	  //m_oStateInput = {nMachineState:Constant.STATE_INIT_CONTAINERS, nError:0}
	  EnterStateMachine(Enum.STATE_INIT_CONTAINERS);	  
   }

   private function LoadSystemFont(sLinkage:String):Void
   {
      trace("SystemInitialization::LoadSystemFont");
      m_cLoader = new MovieClipLoader(); //FontErasDemiITC.swf
	  m_oListener = {onLoadInit:Fxn.FunctionProxy(this, OnSystemFontLoadComplete)};
	  m_cLoader.addListener(m_oListener);
	  m_cLoader.loadClip("Swf/Fonts/FontErasDemiITC.swf", m_mcSysFont);
   }

   private function OnSystemFontLoadComplete(Void):Void
   {
      trace("SystemInitialization::OnSystemFontLoadComplete");
      m_cLoader.removeListener(m_oListener);
      delete m_oListener;
	  delete m_cLoader;
	  EnterStateMachine(Enum.STATE_INIT_GRAPHICS);
   }

   private function LoadGraphics(Void):Void
   {
      trace("SystemInitialization::LoadGraphics");
	  m_cLoader = new MovieClipLoader(); //FontErasDemiITC.swf
	  m_oListener = {onLoadInit:Fxn.FunctionProxy(this, OnGraphicsLoadComplete)};
	  m_cLoader.addListener(m_oListener);
	  m_cLoader.loadClip("Library/SzGraphics.swf", m_mcGraphics);
   }

   private function OnGraphicsLoadComplete(Void):Void
   {
      trace("SystemInitialization::OnGraphicsLoadComplete");
	  m_cLoader.removeListener(m_oListener);
      delete m_oListener;
	  delete m_cLoader;
      EnterStateMachine(Enum.STATE_INIT_MODEL_DATA);
   }

   private function EnterStateMachine(nStateInput:Number):Void
   {
      //trace("SystemInitialization::EnterStateMachine");
      //var nStateInput:Number = m_oStateInput.nMachineState;
	  //trace("INFO: State Input: " + nStateInput);
      switch(nStateInput)
	  {
      case Enum.STATE_INIT_ERROR:
         //trace("ERROR: " + m_oStateInput.nError);
         break;
	  case Enum.STATE_INIT_CONTAINERS:
		 m_mcSysContainer = Fxn.CreateRootMovieClip("SystemContainer_MC", 0, 0, 0); //1st Level
		 //m_mcSysFont = m_mcSysContainer.createEmptyMovieClip("SystemFont_MC", 0); //2nd Level
		 //m_mcGraphics = m_mcSysFont.createEmptyMovieClip("Graphics_MC", 1); //3rd Level
		 //m_oStateInput.nMachineState = Constant.STATE_INIT_SYSTEM_FONT;
		 //EnterStateMachine(Constant.STATE_INIT_SYSTEM_FONT);
		 EnterStateMachine(Enum.STATE_INIT_MODEL_DATA);
		 break;
      case Enum.STATE_INIT_SYSTEM_FONT:
	     LoadSystemFont("Eras_Demi_ITC");
		 //m_oStateInput.nMachineState = Constant.STATE_INIT_GRAPHICS;
		 //EnterStateMachine(Constant.STATE_INIT_GRAPHICS);
		 break;
	  case Enum.STATE_INIT_GRAPHICS:
	     LoadGraphics();
		 //m_oStateInput.nMachineState = Constant.STATE_INIT_MODEL_DATA;
		 //EnterStateMachine(Constant.STATE_INIT_MODEL_DATA);
	     break;
      case Enum.STATE_INIT_MODEL_DATA:
	     m_oModel = new MvcModel();
		 //m_oStateInput.nMachineState = Constant.STATE_INIT_SYSTEM_CONTROLLER;
		 EnterStateMachine(Enum.STATE_INIT_SYSTEM_CONTROLLER);
		 break;
      case Enum.STATE_INIT_SYSTEM_CONTROLLER:
	     m_oSysController = new SystemController(m_oModel, m_mcSysContainer);
		 //m_oStateInput.nMachineState = Constant.STATE_INIT_COMPLETE;
		 EnterStateMachine(Enum.STATE_INIT_COMPLETE);
		 break;
      case Enum.STATE_INIT_COMPLETE:
	     delete this.EnterStateMachine;
		 break;
	  }
   }

   public function destroy(Void):Void
   {
      trace("SystemInitialization::destroy");
      m_oSysController.destroy();
      m_oModel.destroy();
	  delete m_cLoader;
	  delete m_oListener;
	  //delete m_oStateInput;
	  delete m_oModel;
	  delete m_oSysController;
	  m_mcSysContainer.removeMovieClip();
	  m_mcSysFont.removeMovieClip();
   }
}
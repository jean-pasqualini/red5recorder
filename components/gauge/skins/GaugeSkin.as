/**
 * GaugeSkin
 * 
 * All of the Gauge skins are combined into a single class. For the Gauge
 * component, this makes sense because there is very little to the skins.
 * If the component were more complex it might be worthwhile having multiple
 * classes.
 */ 
package components.gauge.skins
{
	import mx.skins.Border;
	import flash.display.Graphics;
	import mx.styles.StyleManager;
	import flash.filters.DropShadowFilter;
	
	import flash.filters.BevelFilter;
	import mx.utils.ColorUtil;
    import mx.core.FlexGlobals;

	public class GaugeSkin extends Border
	{
		public function GaugeSkin()
		{
			super();
		}

		/**
		 * updateDisplayList
		 *
		 * This method is where the skin is actually drawn. Note that its colors, etc.
		 * are taken from the styles set on its parent - the Gauge component itself.
		 * Any style that has not been set is given a default value.
		 *
		 */
		override protected function updateDisplayList( w:Number, h:Number ) : void
		{
			var bgColor:Number = getStyle("backgroundColor");
			if( isNaN(bgColor) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(bgColor)) bgColor = 0xFFFFFF;
			var bgAlpha:Number = getStyle("backgroundAlpha");
			if( isNaN(bgAlpha) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(bgAlpha) ) bgAlpha = .85;
			var borderColor:Number = getStyle("borderColor");
			if( isNaN(borderColor) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(borderColor) ) borderColor = 0x606060;
			var borderAlpha:Number = getStyle("borderAlpha");
			if( isNaN(borderAlpha) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(borderAlpha) ) borderAlpha = 1;
			var borderSize:Number = getStyle("borderThickness");
			if( isNaN(borderSize) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(borderSize) ) borderSize = 1;
			var needleColor:Number = getStyle("needleColor");
			if( isNaN(needleColor) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(needleColor) ) needleColor = 0x000000;
			var needleThickness:Number = getStyle("needleThickness");
			if( isNaN(needleThickness) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(needleThickness) ) needleThickness = 3;
			var needleAlpha:Number = getStyle("needleAlpha");
			if( isNaN(needleAlpha) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(needleAlpha) ) needleAlpha = 1;
			var coverColor:Number = getStyle("coverColor");
			if( isNaN(coverColor) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(coverColor) ) coverColor = 0x606060;
			var coverAlpha:Number = getStyle("coverAlpha");
			if( isNaN(coverAlpha) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(coverAlpha) ) coverAlpha = 1;
			var coverDropShadowEnabled:Boolean = getStyle("coverDropShadowEnabled");
			//if( isNaN(coverDropShadowEnabled) || !FlexGlobals.topLevelApplication.styleManager.isValidStyleValue(coverDropShadowEnabled) ) coverDropShadowEnabled = true;
			
			var g:Graphics = graphics;
			
			g.clear();
			
			// the name property determines which skin is being drawn.
			
			switch( name )
			{
				case "frameSkin":
					g.lineStyle( borderSize, borderColor, borderAlpha );
					g.beginFill( bgColor, bgAlpha );
					//g.drawEllipse(x,y,w,h);
					g.endFill();
					// filters = [ new BevelFilter(4,225,ColorUtil.adjustBrightness2(bgColor,50),1,
										// ColorUtil.adjustBrightness2(bgColor,-50),1) ];
					break;
				case "needleSkin":
					g.lineStyle( needleThickness, needleColor, needleAlpha );
					g.beginFill( bgColor, bgAlpha );
					g.moveTo(0,h);
					g.lineTo(w,h);
					g.lineTo(w,0);
					g.lineTo(0,h);
					g.endFill();
					// filters = [ new BevelFilter(4,225,ColorUtil.adjustBrightness2(bgColor,50),1,
										// ColorUtil.adjustBrightness2(bgColor,-50),1) ];
					break;
				case "coverSkin":
					g.lineStyle( needleThickness, coverColor, coverAlpha );
					g.beginFill( coverColor, coverAlpha );
					g.moveTo(0,h);
					g.lineTo(w,h);
					g.lineTo(w,0);
					g.lineTo(0,h);
					g.endFill();
					// filters = [ new BevelFilter(4,225,ColorUtil.adjustBrightness2(bgColor,50),1,
										// ColorUtil.adjustBrightness2(bgColor,-50),1) ];
					if (coverDropShadowEnabled) filters = [new DropShadowFilter()];
					break;
			}
		}
		
	}
}
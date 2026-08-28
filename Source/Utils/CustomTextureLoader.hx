package utils;

import spine.support.graphics.TextureAtlas.AtlasRegion;
import spine.support.graphics.TextureAtlas.AtlasPage;
import spine.support.graphics.TextureLoader;
import openfl.Assets;
import openfl.display.BitmapData;

// Carregador de texturas do spine
class CustomTextureLoader implements TextureLoader
{
	private var path:String;

	public function new(path:String)
	{
		this.path = path;
	}

	public function loadPage(page:AtlasPage, path:String):Void
	{
		// Acessa os dados do arquivo de textura
		var bitmapData:BitmapData = Assets.getBitmapData(this.path + path);

		// Armazena os dados no AtlasPage
		if (bitmapData != null){
			page.rendererObject = bitmapData;
			page.width = bitmapData.width;
			page.height = bitmapData.height;
		}else{
			throw ("BitmapData não econtrado no caminho: " + this.path + path);
		}
	}

	public function loadRegion(region:AtlasRegion):Void {  }

	public function unloadPage(page:AtlasPage):Void
	{
		cast(page.rendererObject, BitmapData).dispose();
	}
}
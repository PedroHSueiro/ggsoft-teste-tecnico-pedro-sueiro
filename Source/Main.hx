package;

import utils.CustomTextureLoader;
import utils.StringFileHandle;

import spine.attachments.MeshAttachment;
import spine.attachments.Attachment;
import spine.attachments.AtlasAttachmentLoader;
import spine.AnimationStateData;
import spine.Skeleton;
import spine.SkeletonJson;
import spine.SkeletonData;
import spine.AnimationState;
import spine.support.graphics.TextureAtlas;

import openfl.Vector;
import openfl.display.TriangleCulling;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.utils.Assets;

class Main extends Sprite {
	static inline var PATH = "assets/character/";
	static inline var ATLAS = "skeleton.atlas";
	static inline var SKELETON = "skeleton.json";
	static inline var SKELETON_PNG = "skeleton.png";

	static inline var TIMER_INTERVAL_MS:Int = 16;
	
	var skeleton:Skeleton;
	var animationState:AnimationState;
	var atlasTexture:BitmapData;
	
	var timer:haxe.Timer;
	var lastTime:Float = -1;

	public function new() {
		super();

		addCharacter();
		addSimpleTiming();
	}

	/**
	 * --- 1. Instanciação do personagem usando Spine ---
	 * 
	 * Esse método acessa o atlas, textura e dados do skeleton para instanciar o personagem, além de definir
	 * sua posição na cena e inicializar sua animação padrão.
	 * 
	 * Para isso, são utilizadas duas classes de suporte:
	 *  
	 *  - CustomTextureLoader => Responsável por carregar os dados de texturas para a página do atlas
	 *  - StringFileHandle => Transformar o skeleton.json em um arquivo legível para a criação do SkeletonJson
	 * 
	 */

	function addCharacter():Void {
		// Atlas setup
		var atlasData = Assets.getText(PATH + ATLAS);
		var atlas = new TextureAtlas(atlasData, new CustomTextureLoader(PATH)); // Carregamento de textura
		atlasTexture = Assets.getBitmapData(PATH + SKELETON_PNG);

		// Skeleton setup
		var jsonData = Assets.getText(PATH + SKELETON);
		var jsonFile = new StringFileHandle("skeleton", jsonData);
		var skeletonJson:SkeletonJson = new SkeletonJson(new AtlasAttachmentLoader(atlas));
		var skeletonData:SkeletonData = skeletonJson.readSkeletonData(jsonFile);

		// Definição do Skeleton e confirmação de pose
		skeleton = new Skeleton(skeletonData);
		skeleton.setToSetupPose();

		// Ajustes de posição e escala do personagem
		skeleton.scaleX = 0.5;
		skeleton.scaleY = -0.5;
		this.x = stage.stageWidth / 2;
		this.y = stage.stageHeight * 0.8; 
		
		// Setup de animação base (idle)
		var animStateData = new AnimationStateData(skeletonData);
		animationState = new AnimationState(animStateData);
		animationState.setAnimationByName(0, "idle_anim", true);
	}

	/**
	 * --- 2. Timer baseado na demo para update de animação ---
	 * 
	 * Esses métodos são responsáveis por atualizar constantemente o skeleton e as animações do personagem.
	 * Utiliza a base do "timer" disponibilizado na demo do projeto.
	 * 
	 */

	function addSimpleTiming():Void {
		timer = new haxe.Timer(TIMER_INTERVAL_MS);
		timer.run = onTick;
	}

	function onTick():Void {
		var now = haxe.Timer.stamp();
		if (lastTime < 0)
			lastTime = now;
		var dt = now - lastTime;
		lastTime = now;

		// Controle de atualização da animação e da posição do skeleton
		if(animationState != null && skeleton != null){
			animationState.update(dt);
			animationState.apply(skeleton);
			skeleton.updateWorldTransform();
		}

		// Chamada da renderização do personagem
		renderCharacter();
	}

	/**
	 * --- 3. Renderização do personagem com base em triângulos da mesh ---
	 * 
	 * O método precisa identificar os três parâmetros principais para o desenho de cada triângulo da mesh:
	 *  
	 *  - Vértices
	 *  - UVs
	 *  - Indices dos Triângulos
	 * 
	 * Para isso, os dados são adquiridos na leitura da mesh de cada parte do personagem, por meio do seu attachment,
	 * e são armazenados em vetores para popular o método drawTriangles
	 */

	private function renderCharacter():Void {
		if (skeleton == null || atlasTexture == null) return;

		graphics.clear(); // Limpa a tela

		// Acessa cada slot de acordo com sua ordem de renderização
		for (slot in skeleton.drawOrder) {
			var attachment:Attachment = slot.attachment; // Acessa o atachment do slot
			if (attachment == null) continue;

			// Verifica se o tipo de attachment é mesh (nesse caso, o personagem só tem a mesh)
			var className = Type.getClassName(Type.getClass(attachment));
			if (className != null && className.indexOf("MeshAttachment") != -1) {
				var mesh:MeshAttachment = cast attachment;

				// -- 3.1 Vértices

				// Cálculo de vértices
				var numVertices = mesh.worldVerticesLength;
				var rawVertices:Array<Float> = [];
				rawVertices.resize(numVertices);
				mesh.computeWorldVertices(slot, 0, numVertices, rawVertices, 0, 2);

				// Definição dos pontos dos vertices
				var vertices = new Vector<Float>(numVertices, true);
				for (i in 0...numVertices) {
					vertices[i] = rawVertices[i];
				}

				// -- 3.2 UVs

				// Seleção e definição dos pontos das UVs
				var meshUVs = mesh.getUVs().items;
				var vectorUVs = new Vector<Float>(numVertices, true);
				for (i in 0...numVertices) {
					vectorUVs[i] = meshUVs[i];
				}

				// -- 3.3 Triângulos

				// Definição do índice de triângulos da mesh 
				var trianglesList = mesh.getTriangles();
				var meshTriangles = trianglesList.items;
				var numIndices = trianglesList.size > 0 ? trianglesList.size : trianglesList.length;

				// Transforma a lista de triângulos em um vetor
				var triangleIndices = new Vector<Int>(numIndices, true);
				for (i in 0...numIndices) {
					triangleIndices[i] = meshTriangles[i];
				}

				// -- 3.4 Desenhando o personagem

				graphics.beginBitmapFill(atlasTexture, null, true, true); // Aplica a textura

				// Desenha os triângulos com base nos vértices, triângulos e na UV da mesh
				graphics.drawTriangles(vertices, triangleIndices, vectorUVs, TriangleCulling.NONE);
				graphics.endFill();
			}
		}
	}
}
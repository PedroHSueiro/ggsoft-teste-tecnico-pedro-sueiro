package;

import openfl.display.Bitmap;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.utils.Assets;

/**
 * Ponto de partida do teste técnico GGSoft.
 *
 * O que este arquivo faz (e SÓ isso):
 *   1. Carrega e exibe o personagem estático (assets/character/personagem_base.png).
 *   2. Mostra, ao lado, um exemplo bem simples de animação por tempo (um
 *      quadrado que pulsa em loop) — só pra ilustrar o padrão de "tick"
 *      usado neste projeto. NÃO tem relação com o desafio em si.
 *
 * O que este arquivo NÃO faz (e é o que você precisa construir):
 *   - Não recorta o personagem em partes.
 *   - Não monta hierarquia de bones.
 *   - Não anima o personagem.
 * Ver docs/TECNICA_ANIMACAO.md para o enunciado completo do desafio.
 */
class Main extends Sprite {
	static inline var CHARACTER_PATH = "assets/character/personagem_base.png";

	// Intervalo do "tick" do exemplo de animação — ~60 atualizações/s.
	static inline var TIMER_INTERVAL_MS:Int = 16;

	var demoSquare:Shape;
	var demoTimer:haxe.Timer;
	var demoLastTime:Float = -1;
	var demoElapsed:Float = 0;

	public function new() {
		super();

		addCharacter();
		addInstructionsLabel();
		addSimpleTimingDemo();
	}

	// --- 1. Personagem estático (o material bruto do desafio) -------------

	function addCharacter():Void {
		var bitmapData = Assets.getBitmapData(CHARACTER_PATH);
		if (bitmapData == null) {
			trace('Aviso: não achei $CHARACTER_PATH — confira o project.xml/assets.');
			return;
		}
		var bitmap = new Bitmap(bitmapData);
		bitmap.x = 80;
		bitmap.y = 80;
		addChild(bitmap);
	}

	function addInstructionsLabel():Void {
		var label = new TextField();
		label.width = 480;
		label.x = 600;
		label.y = 90;
		label.selectable = false;
		label.multiline = true;
		label.wordWrap = true;
		label.defaultTextFormat = new TextFormat(null, 16, 0x222222);
		label.text = "Personagem estático — sem animação nenhuma ainda.\n\n"
			+ "Seu desafio: recortar essa imagem em partes (cabeça, tronco, "
			+ "braços, pernas) e montar uma animação de IDLE em LOOP, com "
			+ "bone + malha (skinning).\n\n"
			+ "O quadrado à direita é só um exemplo de código de animação "
			+ "por tempo — não é a resposta do desafio.\n\n"
			+ "Detalhes completos: docs/TECNICA_ANIMACAO.md";
		addChild(label);
	}

	// --- 2. Exemplo simples de animação por tempo (não resolve o desafio) -

	function addSimpleTimingDemo():Void {
		demoSquare = new Shape();
		demoSquare.graphics.beginFill(0x56a0d6);
		demoSquare.graphics.drawRect(-30, -30, 60, 60);
		demoSquare.graphics.endFill();
		demoSquare.x = 700;
		demoSquare.y = 500;
		addChild(demoSquare);

		demoTimer = new haxe.Timer(TIMER_INTERVAL_MS);
		demoTimer.run = onDemoTick;
	}

	// Padrão do projeto: haxe.Timer + delta-time real (haxe.Timer.stamp()),
	// não openfl.events.Event.ENTER_FRAME — mantém a animação estável
	// independente da taxa de quadros real do navegador/dispositivo.
	function onDemoTick():Void {
		var now = haxe.Timer.stamp();
		if (demoLastTime < 0)
			demoLastTime = now;
		var dt = now - demoLastTime;
		demoLastTime = now;

		demoElapsed += dt;
		var scale = 1.0 + 0.15 * Math.sin(demoElapsed * 3.0);
		demoSquare.scaleX = scale;
		demoSquare.scaleY = scale;
	}
}

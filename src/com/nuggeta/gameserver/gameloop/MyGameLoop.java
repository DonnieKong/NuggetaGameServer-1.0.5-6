package com.nuggeta.gameserver.gameloop;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.nuggeta.game.core.ngdl.nobjects.GameMessage;
import com.nuggeta.game.core.ngdl.nobjects.NPlayer;
import com.nuggeta.game.core.ngdl.nobjects.NRawGameMessage;
import com.nuggeta.game.core.ngdl.nobjects.NWorldUpdate;
import com.nuggeta.gameserver.model.BasicGameLoop;
import com.nuggeta.gameserver.network.IncomingCommandContext;

public class MyGameLoop extends BasicGameLoop {

	private static Logger log = LoggerFactory.getLogger(MyGameLoop.class);
	
	@Override
	public void onStarted() {

	}

	@Override
	public void onStopped() {

	}

	@Override
	public NWorldUpdate runFrame(List<IncomingCommandContext<GameMessage>> incomingCommands) {
		NWorldUpdate worldUpdate = new NWorldUpdate();
		for (IncomingCommandContext<GameMessage> incomingCommandContext : incomingCommands) {

			NPlayer player = incomingCommandContext.getOwner();
			GameMessage gameMessage = incomingCommandContext.getMessage();

			//by default send the GameMesage to all player in the game except the sender
			try {
	            nuggetaServerAPI.send(gameMessage, getLivePlayers(), player);
            } catch (Exception e) {
            	log.error("Fail to send Message "+gameMessage + " to all players in the game");
            }

		}

		return worldUpdate;
	}

	@Override
	public void onPlayerJoined(NPlayer player) {

	}

	@Override
	public void onPlayerLeft(NPlayer player) {
	}

	@Override
	public void onPlayerConnectionInterrupted(NPlayer player) {

	}

	@Override
	public void onPlayerConnectionResumed(NPlayer player) {

	}

	@Override
	public void onPlayerConnectionLost(NPlayer player) {

	}

	@Override
	public void onPlayerSessionExpired(NPlayer player) {

	}

}

package com.nuggeta.gameserver;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.nuggeta.game.core.ngdl.nobjects.NGame;
import com.nuggeta.game.core.ngdl.nobjects.NGameCharacteristics;
import com.nuggeta.game.core.ngdl.nobjects.NMatchMakingConditions;
import com.nuggeta.game.core.ngdl.nobjects.NPlayer;
import com.nuggeta.game.core.ngdl.nobjects.NPlayerProfile;
import com.nuggeta.gameserver.gameloop.MyGameLoop;
import com.nuggeta.gameserver.model.GameLoop;
import com.nuggeta.gameserver.server.DefaultBasicNugget;
import com.nuggeta.gameserver.server.IncommingRequestStatus;
import com.nuggeta.ngdl.nobjects.Message;
import com.nuggeta.ngdl.nobjects.NRawMessage;


public class MyServer extends DefaultBasicNugget {

	private Logger logger = LoggerFactory.getLogger(MyServer.class);

	@Override
	public void onStarted() {
		logger.info("MyServer Started");
	}

	@Override
	public IncommingRequestStatus onMessage(NPlayer player, Message message) {
		logger.info("Received Message " + message.toString() + " from Player " + player);
		
		// example here we just sent back a raw message to the player
		if (message instanceof NRawMessage) {
			NRawMessage nRawMessage = new NRawMessage();
			nRawMessage.setContent("echo tango");
			try {
				nuggetaServerAPI.send(nRawMessage, player);
			} catch (Exception e) {
				logger.error("Failed to send message to player " + player.getName());
			}
			return IncommingRequestStatus.REQUEST_INTERCEPTED;
		}
		

		return IncommingRequestStatus.GO_WITH_DEFAULT_BEHAVIOR;
	}

	@Override
	public IncommingRequestStatus onAdminMessage(Message message) {

		logger.info("Received Admin Message " + message.toString());

		return IncommingRequestStatus.REQUEST_INTERCEPTED;
	}

	@Override
	public GameLoop createGameLoop() {
		return new MyGameLoop();
	}
	
	
	//Override with your Player Class if needed
	@Override
	public NPlayer newPlayer() {
	    return super.newPlayer();
	}
	
	//Override with your PlayerProfile Class if needed
	@Override
	public NPlayerProfile newPlayerProfile() {
	    return super.newPlayerProfile();
	}
	
	
	
	
	@Override
	public void onPlayerConnected(NPlayer newPlayer) {
	    super.onPlayerConnected(newPlayer);
	    logger.info("onPlayerConnected " + newPlayer);
	}
	
	@Override
	public void onPlayerConnectionInterrupted(NPlayer newPlayer) {
	    super.onPlayerConnectionInterrupted(newPlayer);
	    logger.info("onPlayerConnectionInterrupted " + newPlayer);
	}
	
	@Override
	public void onPlayerConnectionLost(NPlayer newPlayer) {
	    super.onPlayerConnectionLost(newPlayer);
	    logger.info("onPlayerConnectionLost " + newPlayer);
	}
	
	@Override
	public void onPlayerConnectionResumed(NPlayer newPlayer) {
	    super.onPlayerConnectionResumed(newPlayer);
	    logger.info("onPlayerConnectionResumed " + newPlayer);
	}
	
	@Override
	public void onPlayerSessionExpired(NPlayer player) {
	    super.onPlayerSessionExpired(player);
	    logger.info("onPlayerSessionExpired " + player);
	}
	
	/**
	 * Asked by game engine when instance of game is required for example when JoinImmediateGame request not find any game to join. This gives a chance to join a game. 
	 * @param player
	 * @param matchMakingConditions
	 * @return
	 */
	@Override
	public NGame createGame(NPlayer player, NMatchMakingConditions matchMakingConditions) {
		NGame game = new NGame();
		
		//Copy matching criterias on the game 
		game.setMatchMakingConditions(matchMakingConditions);
		
		//LifeCycle Characteristics of the game 
		NGameCharacteristics nGameCharacteristics  = new NGameCharacteristics();
		
		nGameCharacteristics.setMinPlayer(2);
		nGameCharacteristics.setMaxPlayer(2);
		nGameCharacteristics.setAutoStart(true);
		nGameCharacteristics.setAutoStop(true);
		game.setGameCharacteristics(nGameCharacteristics);
		return game;
	}
	
	/**
	 * 
	 * @param player
	 * @param games - by priority 1 - it is games with waiting players or 2 - games with players empty.   
	 * @param matchMakingConditions
	 * @return By default return first game having its matchMakingConditions equals parameter matchMakingConditions. 
	 * In priority it is provide .
	 */
	@Override
	public NGame matchGame(NPlayer player, List<NGame> games, NMatchMakingConditions matchMakingConditions) {
		return super.matchGame(player, games, matchMakingConditions);
	}
	
	
}

/*
Copyright (c) 2011 Flashphoner
All rights reserved. This Code and the accompanying materials
are made available under the terms of the GNU Public License v2.0
which accompanies this distribution, and is available at
http://www.gnu.org/licenses/old-licenses/gpl-2.0.html

Contributors:
    Flashphoner - initial API and implementation

This code and accompanying materials also available under LGPL and MPL license for Flashphoner buyers. Other license versions by negatiation. Write us support@flashphoner.com with any questions.
*/
package com.flashphoner.api
{
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.flashphoner.Logger;
	import com.flashphoner.api.data.ModelLocator;
	import com.flashphoner.api.data.PhoneConfig;
	import com.flashphoner.api.interfaces.APINotify;
	
	import flash.events.*;
	import flash.utils.*;
	
	import mx.collections.ArrayCollection;
	import mx.messaging.errors.MessagingError;
	
	internal class MessageCommand implements ICommand
	{				
		
		public function MessageCommand()
		{
		}	
		
		public function execute( event : CairngormEvent ) : void
		{	
			Logger.info("MessageCommand.execute() event.type "+event.type);
			
			var flashAPI:Flash_API = (event as MessageEvent).flashAPI;					
			var messageObject:Object = (event as MessageEvent).messageObj;
			
			if (messageObject.state=="ACCEPTED" || messageObject.state=="FAILED"){
				//existing message				
				var instantMessage:InstantMessage = flashAPI.findMessageById(messageObject.id);
				if (instantMessage==null){
					Logger.error("Message not found by id: "+messageObject.id);
				}else{
					//update remote state
					instantMessage.state = messageObject.state;
					flashAPI.removeMessage(instantMessage);
					notify(instantMessage,flashAPI,event);					
				}
			}else if (messageObject.state=="RECEIVED"){
				//new incoming message
				notify(messageObject,flashAPI,event);
			}	
			
			
		}
		
		private function notify(messageObject:Object, flashAPI:Flash_API, event:CairngormEvent):void{
			if (event.type == MessageEvent.MESSAGE_EVENT){
				for each (var apiNotify:APINotify in flashAPI.apiNotifys){
					apiNotify.notifyMessage(messageObject);
				}
			}		
		}
	}
}

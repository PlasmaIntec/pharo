Class {
	#name : #ReversiServer,
	#superclass : #Object,
	#instVars : [
		'connectionSocket',
		'isRunningLock',
		'isRunning'
	],
	#classVars : [
		'Server'
	],
	#category : #'Reversi-Game'
}

{ #category : #'as yet unclassified' }
ReversiServer >> initialize [
	super initialize.
	isRunningLock := Mutex new.
	self isRunning: false
]

{ #category : #'as yet unclassified' }
ReversiServer >> interactOnConnection [
	| interactionSocket |
	interactionSocket := connectionSocket
		waitForAcceptFor: 1
		ifTimedOut: [ ^ self ].
	[ self interactUsing: interactionSocket ] fork
]

{ #category : #'as yet unclassified' }
ReversiServer >> interactUsing: interactionSocket [
	| receivedData |
	[ receivedData := interactionSocket receiveDataTimeout: 5.
	receivedData crTrace.
	Transcript
		clear;
		show: receivedData asByteArray asString.
	interactionSocket
		sendData: 'ECHO: ' , (Point from: receivedData asByteArray asString) asString]
		ensure: [ interactionSocket closeAndDestroy ]
]

{ #category : #'as yet unclassified' }
ReversiServer >> isRunning [
	^ isRunningLock critical: [ isRunning ]
]

{ #category : #'as yet unclassified' }
ReversiServer >> isRunning: aBoolean [
	isRunningLock critical: [ isRunning := aBoolean ]
]

{ #category : #'as yet unclassified' }
ReversiServer >> serve [
	[ [ self isRunning ] whileTrue: [ self interactOnConnection ] ]
		ensure: [ connectionSocket closeAndDestroy ]
]

{ #category : #'as yet unclassified' }
ReversiServer >> start [
	isRunningLock
		critical: [ self isRunning
				ifTrue: [ ^ self ].
			self isRunning: true ].
	connectionSocket := Socket newTCP.
	connectionSocket listenOn: 9999 backlogSize: 10.
	[ self serve ] fork
]

{ #category : #'as yet unclassified' }
ReversiServer >> stop [
	self isRunning: false
]

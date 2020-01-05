Class {
	#name : #ReversiServer,
	#superclass : #Object,
	#instVars : [
		'connectionSocket',
		'isRunningLock',
		'isRunning',
		'gameBoard',
		'isClient',
		'ownPort',
		'otherPort'
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
	self isRunning: false.
	gameBoard := GameBoard new update open.
	gameBoard goOnlineWithServer: self
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
ReversiServer >> interactUsing: aSocket [
	| receivedData stream aPoint |
	stream := SocketStream on: aSocket.receivedData := stream upTo: $!.
			aPoint := Point from: receivedData asByteArray asString trim.
			Transcript
				show: aPoint asString;
				cr.
			gameBoard onlineEnemyClickRow: aPoint x col: aPoint y
]

{ #category : #'as yet unclassified' }
ReversiServer >> isRunning [
	^ isRunningLock critical: [ isRunning ]
]

{ #category : #'as yet unclassified' }
ReversiServer >> isRunning: aBoolean [
	isRunningLock critical: [ isRunning := aBoolean ]
]

{ #category : #mutating }
ReversiServer >> placeAtRow: aRow col: aCol [
	| aSocket aStream |
	aSocket := SocketStream openConnectionToHostNamed: 'localhost' port: otherPort.
	aStream := SocketStream on: aSocket.
	aStream sendCommand: (String fromRow: aRow col: aCol) , '!'
]

{ #category : #'as yet unclassified' }
ReversiServer >> serve [
	[ [ self isRunning ] whileTrue: [ self interactOnConnection ] ]
		ensure: [ connectionSocket closeAndDestroy ]
]

{ #category : #'as yet unclassified' }
ReversiServer >> start [
	"assume 9999 is server port and 9998 is client port"

	isRunningLock
		critical: [ self isRunning
				ifTrue: [ ^ self ].
			self isRunning: true ].
	[ connectionSocket := Socket newTCP
		connectToHostNamed: 'localhost'
		port: 9999 ]
		on: Error
		do: [ self usePort: 9998.
			isClient := true.
			otherPort := 9999.
			^ self ].
	self usePort: 9999.
	isClient := false.
	otherPort := 9998
]

{ #category : #'as yet unclassified' }
ReversiServer >> stop [
	self isRunning: false
]

{ #category : #'as yet unclassified' }
ReversiServer >> usePort: aNumber [
	ownPort := aNumber.
	connectionSocket listenOn: aNumber backlogSize: 10.
	[ self serve ] fork
]

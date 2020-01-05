Class {
	#name : #GameBoard,
	#superclass : #Morph,
	#instVars : [
		'container',
		'game',
		'isOnline',
		'isYourTurn',
		'server'
	],
	#category : #'Reversi-Game'
}

{ #category : #accessing }
GameBoard >> container [
	^ container
]

{ #category : #updating }
GameBoard >> createBoard [
	| rowMorph aCell |
	(1 to: game board numberOfRows)
		do: [ :r | 
			rowMorph := Morph new layoutPolicy: RowLayout new.
			(1 to: game board numberOfColumns)
				do: [ :c | 
					aCell := ButtonCell new.
					aCell label: (r + 64) asCharacter asString , c printString.
					aCell extent: 50 @ 50.
					aCell row: r col: c.
					aCell board: self.
					rowMorph addMorphBack: aCell ].
			container addMorphBack: rowMorph ]
]

{ #category : #accessing }
GameBoard >> game [
	^ game
]

{ #category : #accessing }
GameBoard >> goOnlineWithServer: aServer [.
	isOnline := true.
	server := aServer.
]

{ #category : #initialization }
GameBoard >> initialize [
	container := Morph new
		layoutPolicy: TableLayout new;
		color: Color transparent.
	game := Game new.
	isOnline := false.
	isYourTurn := true.
	self createBoard.
	^ self
]

{ #category : #'as yet unclassified' }
GameBoard >> offlineUserClickRow: aRow col: aCol [
	(self game canPlaceAtRow: aRow col: aCol)
		ifFalse: [ ^ self ].
	self game placeAtRow: aRow col: aCol.
	self game show.
	self update.
	self game ai = 'off'
		ifTrue: [ self game swapTurn ].
	self game ai = 'joker'
		ifTrue: [ self game swapTurn.
			self game jokerTurn.
			self game swapTurn ].
	self update.
	container changed
]

{ #category : #'as yet unclassified' }
GameBoard >> onlineEnemyClickRow: aRow col: aCol [
	| enemyPoint |
	Transcript
		show: 'Enemy clicked row: ' , aRow printString , ' col: ' , aCol printString.
	isYourTurn
		ifTrue: [ ^ self ].
	(self game canPlaceAtRow: aRow col: aCol)
		ifFalse: [ ^ self ].
		self yourTurn: true.
	self game placeAtRow: aRow col: aCol.
	self game show.
	self game swapTurn.
	self update.
	container changed
]

{ #category : #'as yet unclassified' }
GameBoard >> onlineUserClickRow: aRow col: aCol [
	isYourTurn
		ifFalse: [ ^ self ].
	(self game canPlaceAtRow: aRow col: aCol)
		ifFalse: [ ^ self ].
	[ server placeAtRow: aRow col: aCol ] fork.
	self yourTurn: false.
	self game placeAtRow: aRow col: aCol.
	self game show.
	self game swapTurn.
	self update.
	container changed
]

{ #category : #'instance creation' }
GameBoard >> open [
	container openInWindow
]

{ #category : #initialization }
GameBoard >> resetContainer [
	container := Morph new
		layoutPolicy: TableLayout new;
		color: Color transparent.
]

{ #category : #updating }
GameBoard >> update [
	(1 to: game board numberOfRows)
		do: [ :r | 
			(1 to: game board numberOfColumns)
				do: [ :c | 
					(game row: r col: c) = $W
						ifTrue: [ self updateBoardAtRow: r col: c color: Color blue ].
					(game row: r col: c) = $B
						ifTrue: [ self updateBoardAtRow: r col: c color: Color black ] ] ]
]

{ #category : #'as yet unclassified' }
GameBoard >> updateBoardAtRow: aRow col: aCol color: aColor [
	((container submorphs at: aRow) submorphs at: aCol) pieceColor: aColor
]

{ #category : #accessing }
GameBoard >> userClickRow: aRow col: aCol [
	isOnline
		ifTrue: [ self onlineUserClickRow: aRow col: aCol ]
		ifFalse: [ self offlineUserClickRow: aRow col: aCol ]
]

{ #category : #'as yet unclassified' }
GameBoard >> yourTurn: aBoolean [ 
isYourTurn := aBoolean
]

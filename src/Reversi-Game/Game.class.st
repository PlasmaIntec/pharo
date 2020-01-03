Class {
	#name : #Game,
	#superclass : #Object,
	#instVars : [
		'board',
		'turn',
		'enemy',
		'ai'
	],
	#category : #'Reversi-Game'
}

{ #category : #'instance creation' }
Game class >> new [
	| a |
	a := super new.
	a setUp.
	^ a
]

{ #category : #accessing }
Game >> ai [
	^ ai
]

{ #category : #'game logic' }
Game >> askUserForPoint [
	| res x y |
	res := UIManager default
		request: 'Enter Point (You are ' , self turn asString , '), e.g. A1'.
	res = 'q'
		ifTrue: [ ^ false ].
	x := (res at: 1) asInteger - 64.
	y := (res at: 2) asInteger - 48.
	^ Point x: x y: y
]

{ #category : #accessing }
Game >> at: aPoint [
	^ board at: aPoint x at: aPoint y
]

{ #category : #accessing }
Game >> board [
	^ board
]

{ #category : #testing }
Game >> canPlaceAtRow: aRow col: aCol [
	^ {(self isOccupiedAtRow: aRow col: aCol) not.
	(self hasNeighboringEnemyAtRow: aRow col: aCol).
	(self hasAllySupportingAtRow: aRow col: aCol).
	((self getNumberOfCapturesAtRow: aRow col: aCol) ~= 0)}
		reduceLeft: [ :a :b | a and: [ b ] ]
]

{ #category : #accessing }
Game >> enemy [
	^ enemy
]

{ #category : #testing }
Game >> from: startPoint to: endPoint by: directionPoint convert: aCharacter [
	(startPoint to: endPoint by: directionPoint)
		do: [ :each | 
			(self row: each x col: each y) = self enemy
				ifTrue: [ self row: each x col: each y put: aCharacter ] ].
			self row: startPoint x col: startPoint y put: aCharacter 
]

{ #category : #accessing }
Game >> getNeighboringPairs [
	| c |
	c := OrderedCollection new.
	#(-1 0 1)
		allPairsDo: [ :first :second | 
			| p |
			p := Point x: first y: second.
			c add: p ].
	c removeAllSuchThat: [ :each | each = (0 @ 0) ].
	^ c
]

{ #category : #accessing }
Game >> getNumberOfCapturesAtRow: aRow col: aCol [
	| n origin |
	n := 0.
	origin := Point x: aRow y: aCol.
	(self getSupportingAlliesAtRow: aRow col: aCol)
				do: [ :each | 
					(self isUnbroken: (self getPiecesFrom: origin to: each)) ifTrue: 
						[ (self getPiecesFrom: origin to: each) do: [ :piece | 
							piece = self enemy
								ifTrue: [ n := n + 1 ] ] ] ].
	^ n
]

{ #category : #accessing }
Game >> getNumberOfLiveCells [
	| n |
	n := 0.
	self
		withLiveCellsDo: [ :i :row :col | 
			n := n + 1. ].
	^ n
]

{ #category : #accessing }
Game >> getPiecesFrom: originPoint to: destinationPoint [
	| direction c x y |
	direction := originPoint directionTo: destinationPoint.
	c := OrderedCollection new.
	x := originPoint x.
	y := originPoint y.
	[ x = destinationPoint x & (y = destinationPoint y) ]
		whileFalse: [ c add: (self row: x col: y).
			x := x + direction x.
			y := y + direction y ].
		c add: (self row: x col: y).
	^ c
]

{ #category : #accessing }
Game >> getSupportingAlliesAtRow: aRow col: aCol [
	| c b |
	c := OrderedCollection new.
	self getNeighboringPairs
		do: [ :pair | 
			b := (Point x: aRow y: aCol) direction: pair board: self piece: self turn.
			b = false
				ifFalse: [ c add: b ] ].
	^ c
]

{ #category : #testing }
Game >> hasAllySupportingAtRow: aRow col: aCol [
	self getNeighboringPairs
		do: [ :pair | 
			| x y |
			x := aRow + pair x.
			y := aCol + pair y.
			[ {(x > 0).
			(x < 9).
			(y > 0).
			(y < 9)} reduceLeft: [ :a :b | a and: [ b ] ] ]
				whileTrue: [ (self row: x col: y) = self turn
						ifTrue: [ ^ true ].
					x := x + pair x.
					y := y + pair y ] ].
	^ false
]

{ #category : #testing }
Game >> hasNeighboringEnemyAtRow: aRow col: aCol [
	self getNeighboringPairs
		do: [ :each | 
			({(aRow + each x > 0).
			(aRow + each x < 9).
			(aCol + each y > 0).
			(aCol + each y < 9)} reduceLeft: [ :a :b | a and: [ b ] ])
				ifTrue: [ (self row: aRow + each x col: aCol + each y) = self enemy
						ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : #testing }
Game >> isOccupiedAtRow: aRow col: aCol [
	^ (self row: aRow col: aCol) ~= $0
]

{ #category : #accessing }
Game >> isUnbroken: aCollection [
	aCollection removeAt: 1.
	^ aCollection
		allSatisfy: [ :piece | piece = turn or: [ piece = enemy ] ]
]

{ #category : #mutating }
Game >> jokerTurn [
	| c r |
	c := OrderedCollection new.
	self
		withLiveCellsDo: [ :each :row :col | c add: (Point x: row y: col) ].
	r := c atRandom.
	self placeAtRow: r x col: r y.
]

{ #category : #mutating }
Game >> placeAtRow: aRow col: aCol [
	(self canPlaceAtRow: aRow col: aCol)
		ifTrue: [ (self getSupportingAlliesAtRow: aRow col: aCol)
				do: [ :each | 
					| origin |
					origin := Point x: aRow y: aCol.
					self
						from: origin
						to: each
						by: (origin directionTo: each)
						convert: self turn ].
			Transcript
				show:
					'Placed ' , self turn asString , ' at '
						, (Point x: aRow y: aCol) asString;
				cr. ]
		ifFalse: [ Transcript
				show:
					'Cannot place ' , self turn asString , ' at '
						, (Point x: aRow y: aCol) asString;
				cr ].
	^ self
]

{ #category : #'game logic' }
Game >> play [
	| res x y |
	self show.
	res := self askUserForPoint.
	[ res = false ]
		whileFalse: [ x := res x.
			y := res y.
			self placeAtRow: x col: y.
			self show.
			self ai = 'off'
				ifTrue: [ self swapTurn ].
			self ai = 'joker'
				ifTrue: [ self swapTurn.
					self jokerTurn.
					self swapTurn ].
			self show.
			res := self askUserForPoint.
			self getNumberOfLiveCells = 0
				ifTrue: [ Transcript
						show: self enemy , ' has won';
						cr.
					^ true ] ]
]

{ #category : #accessing }
Game >> row: aRow col: aCol [
	^ board at: aRow at: aCol
]

{ #category : #mutating }
Game >> row: aRow col: aCol put: aCharacter [
	board at: aRow at: aCol put: aCharacter
]

{ #category : #initialization }
Game >> setUp [
	board := Array2D rows: 8 columns: 8 element: $0.
	board at: 4 at: 4 put: $W.
	board at: 4 at: 5 put: $B.
	board at: 5 at: 4 put: $B.
	board at: 5 at: 5 put: $W.
	turn := $W.
	enemy := $B.
	ai := 'off'
]

{ #category : #accessing }
Game >> show [
	Transcript space space.
	(1 to: self board numberOfColumns)
		do: [ :c | Transcript show: c asString ]
		separatedBy: [ Transcript space ].
	Transcript cr.
	(1 to: self board numberOfRows)
		do: [ :r | 
			Transcript
				show: (64 + r) asCharacter asString;
				space.
			(self board atRow: r)
				do: [ :each | Transcript show: each asString ]
				separatedBy: [ Transcript space ].
			Transcript
				space;
				show: (64 + r) asCharacter asString ]
		separatedBy: [ Transcript cr ].
	Transcript cr.
	Transcript space space.
	(1 to: self board numberOfColumns)
		do: [ :c | Transcript show: c asString ]
		separatedBy: [ Transcript space ].
	Transcript cr.
]

{ #category : #mutating }
Game >> swapTurn [
| temp |
temp := self turn.
			turn := self enemy.
			enemy := temp
]

{ #category : #accessing }
Game >> turn [
	^ turn
]

{ #category : #mutating }
Game >> withLiveCellsDo: aBlock [
	self board
		withIndicesDo: [ :i :row :col | 
			(self canPlaceAtRow: row col: col)
				ifTrue: [ aBlock value: i value: row value: col ] ]
]

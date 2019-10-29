Extension { #name : #Point }

{ #category : #'*Reversi-Game' }
Point >> direction: pair board: board piece: aCharacter [
	| aRow aCol x1 y1 |
	aRow := self x.
	aCol := self y.
	x1 := aRow + pair x.
	y1 := aCol + pair y.
	[ {(x1 > 0).
	(x1 < 9).
	(y1 > 0).
	(y1 < 9)} reduceLeft: [ :a :b | a and: [ b ] ] ]
		whileTrue: [ (board row: x1 col: y1) = aCharacter
				ifTrue: [ ^ Point x: x1 y: y1 ].
			x1 := x1 + pair x.
			y1 := y1 + pair y ].
	^ false
]

{ #category : #'*Reversi-Game' }
Point >> directionTo: aPoint [
	| dx dy |
	dx := aPoint x - self x.
	dy := aPoint y - self y.
	dx = 0 ifFalse: [ dx := dx / dx abs ].
	dy = 0 ifFalse: [ dy := dy / dy abs ].
	^ Point x: dx y: dy
]

{ #category : #'*Reversi-Game' }
Point >> to: destinationPoint by: directionPoint [
	| c a b |
	c := OrderedCollection new.
	a := x.
	b := y.
	[ a = destinationPoint x & b = destinationPoint y ] whileFalse: [ c add: (Point x: a y: b).
		a := a + directionPoint x.
		b := b + directionPoint y. ].
	c add: (Point x: a y: b).
	^ c
]

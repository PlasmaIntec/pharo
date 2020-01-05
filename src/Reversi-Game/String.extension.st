Extension { #name : #String }

{ #category : #'*Reversi-Game' }
String class >> fromRow: aRow col: aCol [
^ ((aRow+64) asCharacter asString, (aCol+48) asCharacter asString)
]

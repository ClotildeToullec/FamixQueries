Class {
	#name : #FQNAryQueryTest,
	#superclass : #FQAbstractQueryTest,
	#category : #'Famix-Queries-Tests-N-ary'
}

{ #category : #testing }
FQNAryQueryTest class >> isAbstract [
	^ self == FQNAryQueryTest
]

{ #category : #running }
FQNAryQueryTest >> expectedResult [
	^ self subclassResponsibility
]

{ #category : #parents }
FQNAryQueryTest >> firstParentOfQuery [
	^ query subqueries first
]

{ #category : #parents }
FQNAryQueryTest >> newBooleanParent [
	^ FQBooleanQuery new property: #isAbstract
]

{ #category : #parents }
FQNAryQueryTest >> newInvalidParent [
	^ FQBooleanQuery new
]

{ #category : #parents }
FQNAryQueryTest >> newNavigationParent [
	^ FQNavigationQuery incoming
		associations:
			{FamixStReference.
			FamixStInheritance}
]

{ #category : #running }
FQNAryQueryTest >> newQuery [
	"This gives different, non-empty results for each binary query"

	| firstParentQuery secondParentQuery |
	firstParentQuery := self newNavigationParent.
	secondParentQuery := self newTypeParent.
	^ self unConfiguredQuery
		beChildOf:
			{firstParentQuery.
			secondParentQuery}
]

{ #category : #parents }
FQNAryQueryTest >> newStringParent [
	^ FQStringQuery new
		property: #name;
		comparator: #beginsWith:;
		valueToCompare: 'LANP'
]

{ #category : #parents }
FQNAryQueryTest >> newTypeParent [
	^ FQTypeQuery new type: FamixStClass
]

{ #category : #tests }
FQNAryQueryTest >> parentQueriesResult [
	^ {self firstParentOfQuery.
	self secondParentOfQuery}
		collect: [ :q | q runOn: helper classesAndMethods ]
]

{ #category : #parents }
FQNAryQueryTest >> secondParentOfQuery [
	^ query subqueries second
]

{ #category : #tests }
FQNAryQueryTest >> testBeChildOf [
	| parents |
	parents := {self newBooleanParent.
	self newTypeParent}.
	query := self unConfiguredQuery beChildOf: parents.

	self assertCollection: query subqueries hasSameElements: parents.

	self assert: (parents first children includes: query).
	self assert: (parents second children includes: query)
]

{ #category : #tests }
FQNAryQueryTest >> testIsValid [
	self
		deny:
			(self unConfiguredQuery
				beChildOf:
					{self newTypeParent.
					self newInvalidParent}) isValid
]

{ #category : #tests }
FQNAryQueryTest >> testParentSequence [
	"One generation"
	self
		assertCollection: query parentSequence
		hasSameElements:
			{self firstParentOfQuery.
			self secondParentOfQuery.
			query}.

	"Two generations"
	query subqueries first beChildOf: self newBooleanParent.
	query subqueries second beChildOf: self newStringParent.
	self
		assertCollection: query parentSequence
		hasSameElements:
			{self firstParentOfQuery parent.
			self firstParentOfQuery.
			self secondParentOfQuery parent.
			self secondParentOfQuery.
			query}
]

{ #category : #tests }
FQNAryQueryTest >> testParents [
	| newParents previousParents |
	newParents := {self newBooleanParent.
	self newBooleanParent}.
	previousParents := query subqueries.

	query subqueries: newParents.
	self assert: query subqueries equals: newParents.
	self deny: (query subqueries includesAny: previousParents)
]

{ #category : #tests }
FQNAryQueryTest >> testResult [
	query subqueries
		do:
			[ :parent | parent parent: (FQRootQuery new result: helper classesAndMethods) ].
	self
		assertCollection: query result
		hasSameElements: (query runOn: self parentQueriesResult)
]

{ #category : #'tests - running' }
FQNAryQueryTest >> testRunOn [
	self assert: self expectedResult isNotEmpty.
	self
		assertCollection:
			(query runOn: self parentQueriesResult)
		hasSameElements: self expectedResult
]

//
//  SlideGameHO.swift
//  PulsePace
//
//  Created by James Chiu on 13/3/23.
//

import Foundation
import simd

// Straight slider
class SlideGameHO: GameHO {
    typealias Vector2 = SIMD2<Double>
    typealias CommandType = SlideCommandHO

    let wrappingObject: Entity
    let position: CGPoint
    let vertices: [CGPoint]
    // Each waypoint is between 0 and 1
    let verticeBeatpoints: [Double]
    private var currEdgeIndex = 0

    let lifeStart: Double
    let optimalStart: Double
    let optimalStageStart: LifeStage
    let optimalLife: Double
    let optimalEnd: Double
    let optimalStageEnd: LifeStage
    let lifeEnd: Double
    // lifestage is clamped between 0 and 1, 0.5 being the optimal
    var lifeStage = LifeStage.startStage
    var onLifeEnd: [(SlideGameHO) -> Void] = []

    let startPosition: CGPoint
    var expectedPosition: CGPoint
    let endPosition: CGPoint

    var command: SlideCommandHO

    init(slideHO: SlideHitObject, wrappingObject: Entity, preSpawnInterval: Double, slideSpeed: Double) {
        guard let lastVertice = slideHO.vertices.last else {
            fatalError("Each slider hit object should at least have two vertices")
        }

        self.position = slideHO.position
        self.vertices = slideHO.vertices
        self.wrappingObject = wrappingObject

        self.lifeStart = slideHO.beat - preSpawnInterval
        self.optimalStart = slideHO.beat

        let waypointData = SlideGameHO.populateWaypoints(
            slideSpeed: slideSpeed,
            optimalStart: slideHO.beat,
            position: slideHO.position,
            vertices: slideHO.vertices
        )
        self.optimalLife = waypointData.0
        self.verticeBeatpoints = waypointData.1
        self.optimalEnd = slideHO.beat + optimalLife
        self.lifeEnd = slideHO.beat + optimalLife + preSpawnInterval
        let normSpawnInterval = Lerper.linearFloat(
            from: 0,
            to: 1,
            t: preSpawnInterval / (waypointData.0 + preSpawnInterval * 2)
        )
        self.optimalStageStart = LifeStage(normSpawnInterval)
        self.optimalStageEnd = LifeStage(1 - normSpawnInterval)

        self.startPosition = slideHO.position
        self.endPosition = lastVertice
        self.expectedPosition = slideHO.position

        self.command = SlideCommandHO()
    }

    func updateState(currBeat: Double) {
        setExpectedPosition(currBeat: currBeat)

        lifeStage = LifeStage(Lerper.linearFloat(from: 0, to: 1, t: abs(currBeat - lifeStart) / lifeTime))
        if currBeat - lifeStart >= lifeTime {
            destroyObject()
        }
    }

    private func setExpectedPosition(currBeat: Double) {
        let startBeat = verticeBeatpoints[currEdgeIndex]
        let endBeat = verticeBeatpoints[currEdgeIndex + 1]
        var edgeProgress = (currBeat - startBeat) / (endBeat - startBeat)

        while edgeProgress >= 1 {
            edgeProgress -= 1
            currEdgeIndex += 1
        }

        if currEdgeIndex >= vertices.count {
            return
        }

        let startPoint = currEdgeIndex == 0 ? position : vertices[currEdgeIndex - 1]
        let endPoint = vertices[currEdgeIndex]

        expectedPosition = Lerper.linearVector2(from: startPoint, to: endPoint, t: edgeProgress)
    }

    private static func populateWaypoints(
        slideSpeed: Double,
        optimalStart: Double,
        position: CGPoint,
        vertices: [CGPoint]) -> (Double, [Double]
    ) {
        var currBeatpoint = optimalStart
        var lastVertice = position
        var verticeBeatpoints = [currBeatpoint]
        for vertice in vertices {
            let interval = simd_length(
                Vector2(
                    x: vertice.x - lastVertice.x,
                    y: vertice.y - lastVertice.y
                )
            ) / slideSpeed
            currBeatpoint += interval
            verticeBeatpoints.append(currBeatpoint)
            lastVertice = vertice
        }

        guard let lastBeatpoint = verticeBeatpoints.last else {
            fatalError("Slider must at least have two vertices")
        }

        return (lastBeatpoint - optimalStart, verticeBeatpoints)
    }
}

//
//  AKSequencerTrack.swift
//  AudioKit
//
//  Created by Jeff Cooper on 10/18/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public class AKSequencerTrack {

    var engine: AKSequencerTrackEngine!
    var _events = [AKMIDIEvent]()
    public var events: [AKMIDIEvent] { return _events }
    public var trackID: Int = 0 { didSet { engine.trackIndex = Int32(trackID) } }
    public var lengthInBeats: Double = 4 { didSet { engine.setLengthInBeats(lengthInBeats, at: AVAudioTime.now()) } }
    public var tempo: Double = 120 {
        didSet {
            let now = AVAudioTime(hostTime: mach_absolute_time())
            engine.setTempo(tempo, at: now)
        }

    }
    public var loopEnabled: Bool = true { didSet { engine.maximumPlayCount = loopEnabled ? 0 : 1 } }
    public var isPlaying: Bool { return engine.isPlaying }
    public var targetNode: AKNode

    init(_ node: AKNode, index: Int = 0) {
        engine = AKSequencerTrackEngine(node, index: Int32(index))
        targetNode = node
    }

    init(midiPort: MIDIPortRef, midiEndpoint: MIDIEndpointRef, node: AKNode, index: Int = 0) {
        engine = AKSequencerTrackEngine(midiPort, midiEndpoint: midiEndpoint, node: node, index: Int32(index))
        targetNode = node
    }

    public func add(event: AKMIDIEvent, at position: Double) {
        if let status = event.status {
            let statusByte = status.byte
            let data1 = event.internalData.count > 1 ? event.internalData[1] : 0
            let data2 = event.internalData.count > 2 ? event.internalData[2] : 0
            engine.addMIDIEvent(statusByte, data1: data1, data2: data2, at: position)
        }
    }

    public func add(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, at: Double, duration: Double) {
        engine.addNote(noteNumber, velocity: velocity, at: at, duration: duration)
    }

    public func playOnNextBeat(at beatTime: Double = 0) {
        engine.setBeatTime(-1.0 * beatTime, at: nil)
        engine.play()
    }

    public func add(controller: UInt8, value: UInt8, at: Double, channel: UInt8) {
        let status = AKMIDIStatusType.controllerChange.with(channel: channel)
        engine.addMIDIEvent(status, data1: controller, data2: value, at: at)
    }

    public func play() {
        engine.setBeatTime(0, at: nil)
        engine.play()
    }

    public func stop() {
        engine.stop()
        engine.setBeatTime(0, at: nil)
    }

    public func seek(to time: Double, at position: AVAudioTime? = nil) {
        engine.setBeatTime(time, at: position)
    }

    public func clear() {
        engine.clear()
    }

    public func stopAllNotes() {
        engine.stopAllNotes()
    }

    public func stopAfterCurrentNotes() {
        engine.stopAfterCurrentNotes()
    }

}

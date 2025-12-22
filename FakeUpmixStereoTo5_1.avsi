#============================================================
#  FakeUpmixStereoTo5_1.avsi
#------------------------------------------------------------
#  Description:
#    Creates a synthetic 6-channel (5.1) audio mix from a
#    standard stereo source. Intended for testing purposes,
#    e.g., to verify downmix or channel-mapping functions.
#
#  Compatibility:
#    - AviSynth+ 3.4 and later (32-bit and 64-bit)
#    - AviSynth 2.6 (classic builds)
#    - AviSynth 2.5.8 (works, but may require float support)
#
#  Notes:
#    • Requires only built-in AviSynth functions.
#    • Input must have exactly 2 audio channels (stereo).
#    • No external plugins needed.
#
#  Author:
#    CluelessCoder73
#
#============================================================

Function FakeUpmixStereoTo5_1(clip a)
{
    a = a.ConvertAudioToFloat()          # safer for mixing

    # Split original stereo
    L = GetChannel(a, 1)                 # Left
    R = GetChannel(a, 2)                 # Right

    # Center: mono (L+R) at -3 dB
    C = MixAudio(L, R, 0.5, 0.5)

    # LFE: mono (L+R) at lower level (no low-pass, just reduced volume)
    LFE = MixAudio(L, R, 0.25, 0.25)     # -6 dB vs center

    # Surrounds: delayed, slightly lower level copies of L/R
    SL = DelayAudio(L, 0.02).Amplify(0.7)  # ~20 ms delay
    SR = DelayAudio(R, 0.02).Amplify(0.7)

    # Merge to 6 channels: FL, FR, FC, LFE, SL, SR
    return MergeChannels(L, R, C, LFE, SL, SR)
}

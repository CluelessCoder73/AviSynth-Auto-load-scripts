#============================================================
#  Downmix6ToStereo.avsi
#------------------------------------------------------------
#  Description:
#    Collection of simple audio utility functions:
#      • Downmix6ToStereo   - Downmixes 6-channel (5.1) audio to stereo
#      • FakeUpmixStereoTo5_1 - Creates a synthetic 5.1 mix from stereo
#
#  Usage:
#    Downmix6ToStereo(clip a [, float "center_gain", float "surround_gain", float "lfe_gain"])
#    FakeUpmixStereoTo5_1(clip a)
#
#  Compatibility:
#    - AviSynth+ 3.4 and later (32-bit and 64-bit)
#    - AviSynth 2.5.8 and later
#
#  Notes:
#    • Functions use only core AviSynth filters (no external plugins required).
#    • Downmix6ToStereo expects 6 discrete channels in this order:
#         FL, FR, FC, LFE, SL, SR
#    • FakeUpmixStereoTo5_1 expects exactly 2 audio channels (stereo).
#
#  Author:
#    CluelessCoder73
#
#============================================================

#------------------------------------------------------------
#  Downmix6ToStereo
#------------------------------------------------------------
#  Description:
#    Downmixes 6-channel (5.1) audio to stereo.
#    The mix levels for Center, Surround, and LFE channels
#    can be adjusted via parameters.
#
#  Parameters:
#    center_gain   - Gain applied to Center channel (default 0.7071)
#    surround_gain - Gain applied to Surround channels (default 0.7071)
#    lfe_gain      - Gain applied to LFE channel (default 0.0)
#
#  Notes:
#    • Input must contain 6 discrete audio channels in the order:
#         FL, FR, FC, LFE, SL, SR
#
#------------------------------------------------------------

# Downmix6ToStereo(clip a, float "center_gain"=0.7071, float "surround_gain"=0.7071, float "lfe_gain"=0.0)
Function Downmix6ToStereo(clip a, float "center_gain", float "surround_gain", float "lfe_gain")
{
    center_gain   = Default(center_gain,   0.7071)
    surround_gain = Default(surround_gain, 0.7071)
    lfe_gain      = Default(lfe_gain,      0.0)

    FL  = GetChannel(a, 1) # Front Left
    FR  = GetChannel(a, 2) # Front Right
    FC  = GetChannel(a, 3) # Front Center
    LFE = GetChannel(a, 4) # LFE
    SL  = GetChannel(a, 5) # Surround Left
    SR  = GetChannel(a, 6) # Surround Right

    # Build Left channel
    LeftMix = MixAudio(FL, FC, 1.0, center_gain)
    LeftMix = MixAudio(LeftMix, SL, 1.0, surround_gain)
    LeftMix = MixAudio(LeftMix, LFE, 1.0, lfe_gain)

    # Build Right channel
    RightMix = MixAudio(FR, FC, 1.0, center_gain)
    RightMix = MixAudio(RightMix, SR, 1.0, surround_gain)
    RightMix = MixAudio(RightMix, LFE, 1.0, lfe_gain)

    return MergeChannels(LeftMix, RightMix)
}


#------------------------------------------------------------
#  FakeUpmixStereoTo5_1
#------------------------------------------------------------
#  Description:
#    Creates a synthetic 6-channel (5.1) audio mix from a
#    standard stereo source. Intended for testing purposes,
#    e.g., to verify downmix or channel-mapping functions.
#
#  Notes:
#    • Input must have exactly 2 audio channels (stereo).
#
#------------------------------------------------------------

Function FakeUpmixStereoTo5_1(clip a)
{
    a = a.ConvertAudioToFloat()            # safer for mixing

    # Split original stereo
    L = GetChannel(a, 1)                   # Left
    R = GetChannel(a, 2)                   # Right

    # Center: mono (L+R) at -3 dB
    C = MixAudio(L, R, 0.5, 0.5)

    # LFE: mono (L+R) at lower level (no low-pass, just reduced volume)
    LFE = MixAudio(L, R, 0.25, 0.25)       # -6 dB vs center

    # Surrounds: delayed, slightly lower level copies of L/R
    SL = DelayAudio(L, 0.02).Amplify(0.7)  # ~20 ms delay
    SR = DelayAudio(R, 0.02).Amplify(0.7)

    # Merge to 6 channels: FL, FR, FC, LFE, SL, SR
    return MergeChannels(L, R, C, LFE, SL, SR)
}

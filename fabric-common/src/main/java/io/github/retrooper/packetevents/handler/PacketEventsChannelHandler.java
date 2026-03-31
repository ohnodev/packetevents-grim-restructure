package io.github.retrooper.packetevents.handler;

import com.github.retrooper.packetevents.protocol.player.User;

/**
 * Implemented by both intermediary and official PacketDecoder/PacketEncoder
 * so FabricChannelInjector can update user and player references
 * without depending on mapping-specific types.
 */
public interface PacketEventsChannelHandler {
    User getUser();
    void setUser(User user);
    Object getPlayer();
    void setPlayer(Object player);
}

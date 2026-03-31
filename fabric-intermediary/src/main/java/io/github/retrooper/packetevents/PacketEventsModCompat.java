package io.github.retrooper.packetevents;

import com.github.retrooper.packetevents.PacketEvents;
import com.github.retrooper.packetevents.PacketEventsAPI;
import com.github.retrooper.packetevents.protocol.PacketSide;
import net.minecraft.network.ClientConnection;
import net.minecraft.network.NetworkSide;

/**
 * ABI-compatibility shim for mods that called PacketEventsMod.isOurConnection()
 * with yarn-mapped types. This lives in fabric-intermediary because it references
 * intermediary-mapped Minecraft classes.
 */
public class PacketEventsModCompat {

    public static boolean isOurConnection(ClientConnection connection) {
        return isOurConnection(connection.side);
    }

    public static boolean isOurConnection(NetworkSide flow) {
        PacketSide connectionSide = switch (flow) {
            case CLIENTBOUND -> PacketSide.CLIENT;
            case SERVERBOUND -> PacketSide.SERVER;
        };
        PacketEventsAPI<?> api = PacketEvents.getAPI();
        return api != null && api.getInjector().getPacketSide() == connectionSide;
    }
}

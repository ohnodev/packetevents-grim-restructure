package io.github.retrooper.packetevents.mixin;

import com.github.retrooper.packetevents.PacketEvents;
import com.github.retrooper.packetevents.PacketEventsAPI;
import com.github.retrooper.packetevents.event.UserLoginEvent;
import com.github.retrooper.packetevents.protocol.player.User;
import com.github.retrooper.packetevents.util.FakeChannelUtil;
import io.github.retrooper.packetevents.util.FabricUtil;
import io.netty.channel.Channel;
import net.minecraft.network.Connection;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.server.network.CommonListenerCookie;
import net.minecraft.server.players.PlayerList;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfoReturnable;

@Mixin(PlayerList.class)
public class PlayerListMixin {

    @Inject(
            method = "placeNewPlayer",
            at = @At("HEAD")
    )
    private void preNewPlayerPlace(
            Connection connection, ServerPlayer player,
            CommonListenerCookie cookie, CallbackInfo ci
    ) {
        if (FabricUtil.isOurConnection(connection)) {
            PacketEvents.getAPI().getInjector().setPlayer(connection.channel, player);
        }
    }

    @Inject(
            method = "placeNewPlayer",
            at = @At(
                    value = "INVOKE",
                    target = "Lnet/minecraft/server/players/PlayerList;broadcastAll(Lnet/minecraft/network/protocol/Packet;)V",
                    shift = At.Shift.AFTER
            )
    )
    private void onPlayerLogin(
            Connection connection, ServerPlayer player,
            CommonListenerCookie cookie, CallbackInfo ci
    ) {
        if (!FabricUtil.isOurConnection(connection)) {
            return;
        }

        PacketEventsAPI<?> api = PacketEvents.getAPI();
        User user = api.getPlayerManager().getUser(player);
        if (user == null) {
            Object channelObj = api.getPlayerManager().getChannel(player);

            if (!FakeChannelUtil.isFakeChannel(channelObj) &&
                    (!api.isTerminated() || api.getSettings().isKickIfTerminated())) {
                player.connection.disconnect(Component.literal("PacketEvents failed to inject into a channel."));
            }
            return;
        }

        api.getEventManager().callEvent(new UserLoginEvent(user, player));
    }

    @Inject(
            method = "respawn",
            at = @At("RETURN")
    )
    private void postRespawn(CallbackInfoReturnable<ServerPlayer> cir) {
        ServerPlayer player = cir.getReturnValue();
        if (FabricUtil.isOurConnection(player.connection.connection)) {
            Channel channel = player.connection.connection.channel;
            PacketEvents.getAPI().getInjector().setPlayer(channel, player);
        }
    }
}

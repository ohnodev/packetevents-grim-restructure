package io.github.retrooper.packetevents.mixin;

import com.github.retrooper.packetevents.PacketEvents;
import com.github.retrooper.packetevents.PacketEventsAPI;
import com.github.retrooper.packetevents.event.UserConnectEvent;
import com.github.retrooper.packetevents.protocol.ConnectionState;
import com.github.retrooper.packetevents.protocol.PacketSide;
import com.github.retrooper.packetevents.protocol.player.ClientVersion;
import com.github.retrooper.packetevents.protocol.player.User;
import com.github.retrooper.packetevents.protocol.player.UserProfile;
import com.github.retrooper.packetevents.util.PacketEventsImplHelper;
import io.github.retrooper.packetevents.handler.PacketDecoder;
import io.github.retrooper.packetevents.handler.PacketEncoder;
import io.github.retrooper.packetevents.util.FabricUtil;
import io.github.retrooper.packetevents.util.viaversion.ViaVersionUtil;
import io.netty.channel.Channel;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelPipeline;
import net.minecraft.SharedConstants;
import net.minecraft.network.BandwidthDebugMonitor;
import net.minecraft.network.Connection;
import net.minecraft.network.protocol.PacketFlow;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.Unique;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(Connection.class)
public class ConnectionMixin {

    @Unique
    private static final ClientVersion CLIENT_VERSION =
            ClientVersion.getById(SharedConstants.getProtocolVersion());

    @Inject(
            method = "configureSerialization",
            at = @At("TAIL")
    )
    private static void configureSerialization(
            ChannelPipeline pipeline, PacketFlow flow, boolean memoryOnly,
            BandwidthDebugMonitor bandwidthDebugMonitor, CallbackInfo ci
    ) {
        PacketEventsAPI<?> api = PacketEvents.getAPI();
        if (!FabricUtil.isOurConnection(flow)) {
            if (api != null) {
                api.getLogManager().debug("Skipped pipeline injection on " + flow);
            }
            return;
        }

        if (api == null) {
            return;
        }
        api.getLogManager().debug("Game connected!");

        Channel channel = pipeline.channel();
        User user = new User(channel, ConnectionState.HANDSHAKING,
                CLIENT_VERSION, new UserProfile(null, null));
        api.getProtocolManager().setUser(channel, user);

        UserConnectEvent connectEvent = new UserConnectEvent(user);
        api.getEventManager().callEvent(connectEvent);
        if (connectEvent.isCancelled()) {
            api.getProtocolManager().removeUser(channel);
            channel.unsafe().closeForcibly();
            return;
        }

        PacketSide apiSide = api.getInjector().getPacketSide();
        channel.pipeline().addAfter("splitter", PacketEvents.DECODER_NAME, new PacketDecoder(apiSide, user));
        channel.pipeline().addAfter("prepender", PacketEvents.ENCODER_NAME, new PacketEncoder(apiSide, user));

        if (api.getSettings().isPreViaInjection() && ViaVersionUtil.isAvailable(user)) {
            String preDecoderName = "pre-" + PacketEvents.DECODER_NAME;
            String preEncoderName = "pre-" + PacketEvents.ENCODER_NAME;
            if (channel.pipeline().get("via-decoder") != null) {
                channel.pipeline().addBefore("via-decoder", preDecoderName, new PacketDecoder(apiSide, user, true));
            } else {
                channel.pipeline().addAfter("splitter", preDecoderName, new PacketDecoder(apiSide, user, true));
            }
            if (channel.pipeline().get("via-encoder") != null) {
                channel.pipeline().addBefore("via-encoder", preEncoderName, new PacketEncoder(apiSide, user, true));
            } else {
                channel.pipeline().addAfter("prepender", preEncoderName, new PacketEncoder(apiSide, user, true));
            }
        }
        channel.closeFuture().addListener((ChannelFutureListener) future ->
                PacketEventsImplHelper.handleDisconnection(user.getChannel(), user.getUUID()));
    }
}
